"""Preprocess the Yelp Dataset"""
import json


def read_and_process_businesses(json_file_path):
    """Read in the json dataset file and process it line by line."""
    post_codes = {}
    num_businesses = 0
    with open(json_file_path) as fin:
        for line in fin:
            line_contents = json.loads(line)
            pc = line_contents.get('postal_code', 0)
            pc_num = post_codes.get(pc, 0)
            post_codes[pc] = pc_num + 1
            num_businesses += 1

    with open('post_codes.json', 'w') as fp:
        json.dump(post_codes, fp, sort_keys=True, indent=4)

    print("Number of businesses {}".format(num_businesses))


def get_business_ids_in_postal_code(postal_code):
    # get business IDs
    businesses = {}

    with open('../data/yelp_academic_dataset_business.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            pc = line_contents.get('postal_code', 0)
            if pc == postal_code:
                businesses[line_contents.get('business_id')] = {}
                businesses[line_contents.get('business_id')]['name'] = line_contents.get('name')

    with open('businesses.json', 'w') as fp:
        json.dump(businesses, fp, sort_keys=True, indent=4)

    return businesses


def get_reviews_for_businesses(b_to_get_reviews_for):
    fp = open('restautant_reviews.json', 'w')
    num_reviews = 0

    with open('../data/yelp_academic_dataset_review.json') as fin:
        users = {}

        for line in fin:
            line_contents = json.loads(line)
            b_id = line_contents.get("business_id")

            del line_contents['text']
            del line_contents['date']

            if b_id in b_to_get_reviews_for:
                # json.dump(line_contents, fp)
                fp.write("{}\n".format(line_contents))
                num_reviews += 1
                if num_reviews % 1000 == 0:
                    print('{}'.format(num_reviews))

    print("Number of restaurant reviews: {}".format(num_reviews))
    fp.close()


def get_restaurants():
    num_restaurants = 0
    restaurants = []

    with open('../data/yelp_academic_dataset_business.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            at = line_contents.get('categories', [])

            # print("{}".format(at))

            if at is not None:
                if "Restaurants" in at:
                    num_restaurants += 1
                    restaurants.append(line_contents.get("business_id"))

    print("Number of restaurants: {}".format(num_restaurants))

    r = {"restaurants": restaurants}
    with open('restaurants.json', 'w') as fp:
        json.dump(restaurants, fp, sort_keys=True, indent=4)

    return restaurants


def process_restaurant_reviews(src, dest):
    restaurants = {}
    num_restaurants = 0

    with open(src) as fin:
        for line in fin:
            line_contents = json.loads(line)

            b_id = line_contents.get("business_id")
            if b_id not in restaurants:
                num_restaurants += 1
                if num_restaurants % 100 == 0:
                    print("Num Restaurants: {}".format(num_restaurants))
                restaurants[b_id] = {}
                restaurants[b_id]["reviews"] = []

            restaurants[b_id]["reviews"].append(line_contents)

    with open(dest, 'w') as fp:
        json.dump(restaurants, fp, sort_keys=True, indent=4)


def replace_quotes(src, dest):
    fp = open(dest, 'w')
    num_line = 0

    with open(src) as fin:
        for line in fin:
            num_line += 1
            if num_line % 1000 == 0:
                print("Num: {}".format(num_line))
            line = line.replace("'", '"')
            fp.write(line)
    fp.close()


def remove_slash(src, dest):
    fp = open(dest, 'w')
    num_line = 0

    with open(src) as fin:
        for line in fin:
            num_line += 1
            if num_line % 1000 == 0:
                print("Num: {}".format(num_line))
            line = line.replace('\\', "")
            fp.write(line)
    fp.close()


def remove_quotes(src, dest):
    fp = open(dest, 'w')

    fp = open(src, 'r')
    data = json.loads(fp)

    for b_id in data:
        for review in data[b_id]:
            nop


def get_users_from_reviews(src, dest):
    # make a list of the users in reviews
    users = set()

    num_users = 0

    with open(src) as fin:
        for line in fin:
            line_contents = json.loads(line)
            user_id = line_contents.get("user_id")

            if user_id not in users:
                users.add(user_id)
                num_users += 1
                if num_users % 1000 == 0:
                    print("Pre Num Users: {}".format(num_users))

    fp = open(dest, 'w')

    num_users = 0

    # get users info and place into file
    with open('../data/yelp_academic_dataset_user.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            user_id = line_contents.get('user_id')

            if user_id in users:
                fp.write(line)
                num_users += 1
                if num_users % 1000 == 0:
                    print("Post Num Users: {}".format(num_users))

    print("Total Users: {}".format(num_users))


def get_restaurant_subset(src, dest, num):
    new_restaurants = {}
    count = 0

    fp = open(src, 'r')
    data = json.load(fp)

    for b_id in data:
        new_restaurants[b_id] = data[b_id]

        count += 1
        if count > num:
            break

    fp.close()
    fp = open(dest, 'w')
    json.dump(new_restaurants, fp, sort_keys=True, indent=4)


def get_user_subset(restaurant_src, user_src, user_dest):
    restaurant_fp = open(restaurant_src, 'r')
    restaurant_data = json.load(restaurant_fp)
    restaurant_fp.close()

    new_users = set()
    num_users = 0

    for b_id, b_info in restaurant_data.items():
        for review in b_info['reviews']:
            new_users.add(review['user_id'])
            num_users += 1
            if num_users % 10 == 0:
                print("Read Num Users {}".format(num_users))

    del restaurant_data
    num_users = 0

    user_fp = open(user_src, 'r')
    user_data = json.load(user_fp)
    user_fp.close()

    new_user_data = {}
    num_new_users = 0
    for u_id, u_data in user_data.items():
        if u_id in new_users:
            new_user_data[u_id] = u_data
            num_users += 1
            if num_users % 10 == 0:
                print("Gather Num Users {}".format(num_users))

    del user_data

    fp = open(user_dest, 'w')
    json.dump(new_user_data, fp, sort_keys=True, indent=4)


def convert_user_json(src, dest):
    dest_users = {}
    num_users = 0

    with open(src) as fin:
        for line in fin:
            line_contents = json.loads(line)
            user_id = line_contents.get('user_id')
            dest_users[user_id] = line_contents
            num_users += 1
            if num_users % 1000 == 0:
                print("Num Users: {}".format(num_users))

    fp = open(dest, 'w')
    json.dump(dest_users, fp, sort_keys=True, indent=4)

if __name__ == '__main__':
    # import pdb
    # pdb.set_trace()
    # read_and_process_businesses('../data/yelp_academic_dataset_business.json')
    # businesses = get_business_ids_in_postal_code("06502")
    # get_reviews_for_businesses(businesses)
    # myrestaurants = get_restaurants()
    # get_reviews_for_businesses(myrestaurants)
    # process_restaurant_reviews("restaurant_reviews.json", "restaurants.json")
    # get_users_from_reviews("restaurant_reviews.json", "users.json")
    # replace_quotes("restautant_reviews.json", "restaurant_reviews.json")
    # remove_slash("restaurants.json", "restaurants2.json")
    # get_restaurant_subset('restaurants.json', 'restaurants_subset.json', 5)
    # convert_user_json('users.json', 'users_keyed.json')
    get_user_subset('restaurants_subset.json', 'users_keyed.json', 'users_subset.json')