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
    restaurants = {}

    with open('../data/yelp_academic_dataset_business.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            at = line_contents.get('categories', [])

            if at is not None:
                if "Restaurants" in at:
                    num_restaurants += 1
                    restaurants[line_contents.get("business_id")] = line_contents
                    if num_restaurants % 1000 == 0:
                        print("Number of restaurants: {}".format(num_restaurants))

    with open('restaurants.json', 'w') as fp:
        json.dump(restaurants, fp, sort_keys=True, indent=4)


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

    # sum the reviews
    for b_id in data:
        data[b_id]["num_reviews"] = len(data[b_id]["reviews"])

    # select restaurants with only more than num reviews
    for b_id in data:
        if data[b_id]["num_reviews"] > num:
            new_restaurants[b_id] = data[b_id]
            count += 1

    print("Num Restaurants {} with more than {} reviews".format(count, num))

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
            if num_users > 500:
                break

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


def get_business_info(b_id):
    with open('../data/yelp_academic_dataset_business.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            id = line_contents.get("business_id")

            if b_id == id:
                print(line_contents)
                break


def reduce_restaurants(src, dest, num):
   import pdb
   pdb.set_trace()

   new_restaurants = {}
   count = 0

   fp = open(src, 'r')
   data = json.load(fp)

   for b_id in data:
       new_restaurants[b_id] = data[b_id]

       break

   fp.close()
   fp = open(dest, 'w')
   json.dump(new_restaurants, fp, sort_keys=True, indent=4)


def get_noras_user_set():
    """
    In this user set create a josn with users and what they rated noras

    Take all the features that the user has and then create a dictionart.
    """

    ###########################################################################
    # create set of all users that rated noras
    print("Create set of all users that rated Noras")
    users = set()
    fp = open('restaurant_noras_reviews.json')
    data = json.load(fp)
    for r in data["pHJu8tj3sI8eC5aIHLFEfQ"]["reviews"]:
        users.add(r["user_id"])


    fp.close()
    noras_user_profile = {}
    for u in users:
        noras_user_profile[u] = {}
        noras_user_profile[u]["categories"] = []
        noras_user_profile[u]["ratings"] = []

    for r in data["pHJu8tj3sI8eC5aIHLFEfQ"]["reviews"]:
        noras_user_profile[r["user_id"]]["noras_rating"] = r["stars"]


    ###########################################################################
    # Process reviews and create user profiles
    fp = open('restaurants.json')
    restaurants = json.load(fp)

    print("process reviews")
    num_reviews = 0
    with open('../data/yelp_academic_dataset_review.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            u_id = line_contents.get('user_id')
            if u_id in users:
                num_reviews += 1
                if num_reviews % 100 == 0:
                    print("Processing reviews {}".format(num_reviews))

                if line_contents.get('business_id') in restaurants:
                    noras_user_profile[u_id]["ratings"].append(line_contents.get("stars"))

                    r_data = restaurants[line_contents.get('business_id')]
                    for cat in r_data["categories"].split(','):
                        cat = cat.strip()
                        noras_user_profile[u_id]["categories"].append(cat)

    fp.close()

    ###########################################################################
    # compute average restaurant review
    print("computing average restaurant reviews")
    num_reviews = 0
    for u_id in noras_user_profile:
        num_reviews += 1
        if num_reviews % 10 == 0:
            print("computing average {}".format(num_reviews))
        noras_user_profile[u_id]["avg_restaurant_rating"] = sum(noras_user_profile[u_id]["ratings"]) / len(noras_user_profile[u_id]["ratings"])

    ###########################################################################
    # get user data from the user json file
    print("getting other user data")
    num_users = 0
    with open('../data/yelp_academic_dataset_user.json') as fin:
        for line in fin:
            line_contents = json.loads(line)
            u_id = line_contents.get('user_id')
            if u_id in users:
                num_users += 1
                if num_users % 50 == 0:
                    print("getting more user data {}".format(num_users))

                noras_user_profile[u_id]["avg_rating"] = line_contents.get("average_stars")
                noras_user_profile[u_id]["review_count"] = line_contents.get("review_count")
                noras_user_profile[u_id]["useful"] = line_contents.get("useful")

    ###########################################################################
    # convert set to list
    print("convert set to list")
    for u_id in noras_user_profile:
        noras_user_profile[u_id]["categories"] = list(noras_user_profile[u_id]["categories"])

    ###########################################################################
    # write to file
    print("writing to file")
    fp = open('noras_user_profile.json', 'w')
    json.dump(noras_user_profile, fp, sort_keys=True, indent=4)
    fp.close()


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
    # get_restaurant_subset('restaurants.json', 'restaurants_more_than_1000_reviews.json', 1000)
    # convert_user_json('users.json', 'users_keyed.json')

    # get_business_info("pHJu8tj3sI8eC5aIHLFEfQ")
    # get_restaurants()

    # reduce_restaurants('restaurants_more_than_1000_reviews.json', 'restaurant.json', 1)
    # get_user_subset('restaurants_1000_subset.json', 'users_keyed.json', 'user.json')
    get_noras_user_set()