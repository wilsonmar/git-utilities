#!/usr/bin/env python

# github_img_to_cloudinary.py at https://github.com/wilsonmar/git-utilities/master/github_img_to_cloudinary.py
# Based on migrate_to_cloudinary.py at https://gist.github.com/akshay-ranganath/b5e2d9b0c29ddfe676bdf9cd3713cf12

import cloudinary
import cloudinary.uploader
import cloudinary.api
import cloudinary.utils
import argparse
import sys, os, glob, re
import urllib.parse

cloudinary.config(
  cloud_name = '<>',
  api_key = '<>',
  api_secret = '<>'
)


def cli():
    prog = "github_migration.py"
    if len(sys.argv) == 1:
        prog += " [command]"

    parser = argparse.ArgumentParser(
        description='CLI to migration Ghithub blog images to cloudinary',
        add_help=True,
        prog=prog)

    parser.add_argument(
        '--version',
        action='version',
        version='0.1')

    subparsers = parser.add_subparsers(
        title='Commands', dest="command", metavar="")

    actions = {}

    subparsers.add_parser(
        name="help",
        help="Show available help",
        add_help=False).add_argument(
        'args',
        metavar="",
        nargs=argparse.REMAINDER)

    actions["identify"] = create_sub_command(
        subparsers, "identify",
        "Identifies all the images that will be migrated to Cloudinary",
        required_arguments=[{"name": "directory", "help": "Base directory for the github blog project"}],
        optional_arguments=[{"name": "display", "help": "Display all the image names with their file name"}]
    )

    actions["swap"] = create_sub_command(
        subparsers, "swap",
        "Identifies all the images that will be migrated to Cloudinary",
        required_arguments=[{"name": "directory", "help": "Base directory for the github blog project"}],
        optional_arguments=[{"name": "display", "help":"Display all the image names with their file name"}]
    )

    if len(sys.argv) <= 1:
        parser.print_help()
        return 0

    args = parser.parse_args()

    if args.command == "help":
        if len(args.args) > 0:
            if actions[args.args[0]]:
                actions[args.args[0]].print_help()
        else:
            parser.prog = get_prog_name() + " help [command]"
            parser.print_help()
        return 0

    return getattr(sys.modules[__name__], args.command.replace("-", "_"))(args)


def create_sub_command(
        subparsers,
        name,
        help,
        optional_arguments=None,
        required_arguments=None):
    action = subparsers.add_parser(name=name, help=help, add_help=False)

    if required_arguments:
        required = action.add_argument_group("required arguments")
        for arg in required_arguments:
            name = arg["name"]
            del arg["name"]
            required.add_argument("--" + name,
                                  required=True,
                                  **arg,
                                  )

    optional = action.add_argument_group("optional arguments")
    if optional_arguments:
        for arg in optional_arguments:
            name = arg["name"]
            del arg["name"]
            optional.add_argument("--" + name,
                                  required=False,
                                  **arg,
                                  )
    return action


def identify(args):
    markdown_files = get_posts(args.directory)

    image_details = {}
    for each_markdown_file in markdown_files:
        images = find_images_in_post(each_markdown_file)

        #print the details
        image_details[each_markdown_file] = images
        if args.display != None:
            print(each_markdown_file, images)

        #break


    return image_details


def swap(args):
    markdown_files = get_posts(args.directory)
    for each_markdown_file in markdown_files:
        find_and_swap_images_in_post(args.directory, each_markdown_file)
        #break


def find_and_swap_images_in_post(directory, markdown_file_name):
    with open(markdown_file_name, "r") as blog_post:
        print("Migrating file " + markdown_file_name + " ...",end='')
        temp_file_name = os.environ['TMPDIR'] + markdown_file_name.rsplit('/',maxsplit=1)[1]


        with open(temp_file_name, "w") as temp_file:
            for line in blog_post:
                stripped_line = line.strip()
                if stripped_line.startswith("![") and stripped_line.find('](') > -1:
                    result = run_regex(line)

                    if result[1] != None:
                        alt_text = result[0]
                        image = result[1]

                        if image.startswith("http://") or image.startswith("https://"):
                            upload_object = image
                        else:
                            upload_object = directory + image

                        if os.path.isfile(upload_object) == True and upload_object.find('cloudinary.com')==-1:
                            cloudinary_url = upload_to_cloudinary(upload_object,alt_text)
                            line = "![{}]({})\n".format(result[0], cloudinary_url)

                temp_file.write(line)

        #finally move the updated file to old location
        os.rename(temp_file_name, markdown_file_name)
        print(" Completed!")


def upload_to_cloudinary(object,alt_text):
    cloudinary_url = None
    resp = cloudinary.uploader.upload(
        object,
        public_id=urllib.parse.quote(alt_text.strip()),
        invlidate=True,
        folder="blog"
    )
    if resp!=None and "secure_url" in resp:
        cloudinary_url = cleanup_url(resp["secure_url"])
    return cloudinary_url

url_pattern = re.compile("(.+)\/v[0-9]+\/(.+)")
def cleanup_url(url):
    result = url_pattern.match(url)

    return result.group(1)+'/f_auto,q_auto/'+result.group(2)

def find_images_in_post(markdown_file_name):
    images = []
    with open(markdown_file_name,"r") as blog_post:
        for line in blog_post:
            line = line.strip()
            if line.startswith("![") and line.find('](') > -1:
                result = run_regex(line)
                if result[1]!=None :
                    images.append(result[1])

    return images

pattern = re.compile('\!\[(.+)\]\((.+)\)')
def run_regex(line):

    result = pattern.match(line)
    matches = []
    alt_text = None
    location = None

    try:
        if result!= None:
            (alt_text, location) = result.groups()
    except IndexError:
        print("Something went wrong! " + result.group(2))

    return ([alt_text, location])



def get_posts(directory):
    markdown_files = None

    if os.path.exists(directory):
        # todo: make sure the directory ends with a trailing '/'
        posts_folder = directory + "_posts"
        if os.path.exists(posts_folder):
            print("Now checking for posts: " + posts_folder)
            markdown_files = glob.glob(posts_folder + '/' + '*.md')
        else:
            print("Unable to find posts in the _posts folder!")

    else:
        print("Unable to find directory: " + directory)

    return markdown_files

if __name__ == "__main__":
    cli()