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
    # make list of business ids
    id_list = []
    for id, __ in b_to_get_reviews_for.items():
        id_list.append(id)

    # TODO may wnat to write the line directly to file if there's a lot of reveiws
    with open('../data/yelp_academic_dataset_review.json') as fin:
        users = {}

        for line in fin:
            line_contents = json.loads(line)
            b_id = line_contents.get("business_id")

            if b_id in id_list:
                user = line_contents.get("user_id", 0);
                user_num = users.get(user, 0)
                users[user] = user_num + 1

    with open('users.json', 'w') as fp:
        json.dump(users, fp, sort_keys=True, indent=4)


if __name__ == '__main__':
    # import pdb
    # pdb.set_trace()
    read_and_process_businesses('../data/yelp_academic_dataset_business.json')
    businesses = get_business_ids_in_postal_code("06502")
    get_reviews_for_businesses(businesses)