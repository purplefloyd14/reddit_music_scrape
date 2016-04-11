
require "open-uri"
require 'json'
require "tempfile"
require "date"


data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=20")
#gets top 20 posts from r/listentothis in the past month (usually) in tempfile format

month = Date::MONTHNAMES[Date.today.month]
#the name of the current month


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



def make_dir(month)
  `mkdir #{month}` #creates directory with same name as current month
end


def run_download(url, month) #downloads url audio source as m4a, adds it to month directory
  `youtube-dl -x -f 140 -o\'./#{month}/%(title)s.%(ext)s\' #{url}`
end
#look into using wget to stagger the downloads/know when they are complete


def execute_everything(month, data_from_reddit)
  make_dir(month) #create dir for month
  objectified_data = make_object(data_from_reddit) #make reddit data an object
  url_array = find_urls(objectified_data) #scrapes all urls from object, returns array of urls
  url_array.each do |url| #iterates over url array and downloads file for each url, adding it to month directory
    run_download(url, month)
  end
  #still need
    # move to itunes
    # metadata for itunes (compilations)
    # run once per month
end

execute_everything(month, data_from_reddit)
