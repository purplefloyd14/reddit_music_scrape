require "open-uri"
require 'json'
require "tempfile"
require "date"
require "mp3info"
require "fileutils"

data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=3")
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

def find_titles(data_object)
end

def find_artists(data_object)
end



def make_dir(month)
  `mkdir #{month}` #creates directory with same name as current month
end


def run_download(url, month) #downloads url audio source as m4a, adds it to month directory
  `youtube-dl -x -i -f 140 -o\'./#{month}/%(title)s.%(ext)s\' #{url}`
end


def add_to_itunes(month)
  # p month
  # p month.class
  # dest = "~/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized/"
  `mv ./April/ ~/Music/iTunes/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/`
end

def change_to_mp3(month)
  Dir.glob("./#{month}/*.m4a").each do |f|
    FileUtils.mv f, "#{File.dirname(f)}/#{File.basename(f,'.*')}.mp3"
  end
end


def change_back_to_m4a(month)
  Dir.glob("./#{month}/*.mp3").each do |f|
    FileUtils.mv f, "#{File.dirname(f)}/#{File.basename(f,'.*')}.m4a"
  end
end

def add_metadata(month)
  change_to_mp3(month)
  # dir = "/Users/bradleyneal/Desktop/projects/OpenReddit/#{month}/"
  dir = "./#{month}/"
  Dir.entries(dir).each do |file|
   next if file !~ /.mp3$/ # skip files not ending with .mp3
   p file
   Mp3Info.open(dir + file) do |mp3|
      mp3.tag.album = "#{month}"
      p mp3.tag.album
   end
  end
  change_back_to_m4a(month)
end


def execute_everything(month, data_from_reddit)
  # make_dir(month) #create dir for month
  # objectified_data = make_object(data_from_reddit) #make reddit data an object
  # url_array = find_urls(objectified_data) #scrapes all urls from object, returns array of urls
  # url_array.each_with_index do |url, idx| #iterates over url array and downloads file for each url, adding it to month directory
  #   p url, idx
  #   run_download(url, month)
  # end
  # p "no more urls"
  # change_to_mp3(month)
  # add_metadata(month)
  add_to_itunes(month)
  #still need
    # move to itunes
    # metadata for itunes (compilations)
    # run once per month
end


execute_everything(month, data_from_reddit)
# new_download_method(month)
