require "open-uri" #for getting the data from reddit
require 'json' #for parsing what is returned from reddit
require "tempfile" #working with the large amount of json from reddit
require "date" #month and year items
require "taglib" #tagging metadata
require "find" #for iterating through the songs in the folder
require "mechanize" #for downloading the image from the url


data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=5")
#gets top 20 posts from r/listentothis in the past month (usually) in tempfile format
image_from_reddit = open("http://www.reddit.com/r/earthporn/top.json?sort=top&t=month&limit=1")
#gets top 1 picture from r/earthporn from that month

month = Date::MONTHNAMES[Date.today.month]
year = Date.today.year
#the name of the current month

def get_pic(image_from_reddit)
  agent = Mechanize.new
  link = image_from_reddit
  agent.get(link).save "images/pic.jpg"
end

def tag(month) #this method adds album metadata for all of the tracks in the file
  dir = "./#{month}/"
  Find.find(dir) do |song|
    next if song !~ /.m4a$/
    TagLib::MP4::File.open(song) do |el|
      tag = el.tag
      tag.album = "r/listentothis - #{month}"
      el.save
    end
  end
end


def make_object(data)
  ## this method takes what the reddit api returns, determines its type,
  ## does the appropriate ready-ing (usually tempfile -> string -> JSONparse -> Hash)
  if data.class == Tempfile
    p "temp"
    closer =  IO.read(data.path)
    ready_version = JSON.parse(closer)
    return ready_version
  elsif data.class == StringIO
    p "stringIO"
    ready_version = JSON.parse(data.string)
    return ready_version
  end
end

def get_pic(image_url_string)
  agent = Mechanize.new
  link = image_url_string
  agent.get(link).save
end

def parse_img_data(image_from_reddit)
  objectified_image_data = make_object(image_from_reddit)
  return find_urls(objectified_image_data)[0]
end


def find_urls(data_object)
  #this method iterates through the data object for each post it is given
  #then it adds all of the urls from the data to an array and returns that array
  all_urls = []
  data_object["data"]["children"].each do |post|
    all_urls << post["data"]["url"]
  end
  return all_urls
  #also scrape artist and song title? Could be useful for naming
  #Would use reddit "title" and a regex
end

def find_titles(data_object) #get song_title
end

def find_artists(data_object) #get artist
end



def make_dir(month)
  `mkdir #{month}` #creates directory with same name as current month
end


def run_download(url, month) #downloads url audio source as m4a, adds it to month directory
  `youtube-dl -x -i -f 140 -o\'./#{month}/%(title)s.%(ext)s\' #{url}`
end


def add_to_itunes(month) #adds month folder to itunes library
  `mv ./#{month}/ ~/Music/iTunes/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/`
end


def execute_everything(month, data_from_reddit)
  make_dir(month) #create dir for month
  objectified_data = make_object(data_from_reddit) #make reddit data an object
  url_array = find_urls(objectified_data) #scrapes all urls from object, returns array of urls
  url_array.each_with_index do |url, idx| #iterates over url array and downloads file for each url, adding it to month directory
    p url, idx
    run_download(url, month)
  end
  p "no more urls"
  tag(month)
  add_to_itunes(month)
  a = parse_img_data(image_from_reddit)
  get_pic(a)
  #still need
    # metadata for itunes (compilations)
    # cover art
    # 100% success rate
    # run once per month
end


execute_everything(month, data_from_reddit)
