
require "open-uri"
require 'json'
require "tempfile"

data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=10")


def find_title(thing)
  #this method iterates through the data for each post it is given
  #then it adds all of the titles from the data to an array and returns that array
  all_titles = []
  thing["data"]["children"].each do |post|
    all_titles << post["data"]["title"]
  end
  p all_titles
end

def make_string(data)
  ## this method takes what the reddit api returns, determines its type,
  ## does the appropriate ready-ing and then sends it to find_title
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


def execute_everything(data)
  # this method just calls the other two methods in order
  objectified_data = make_string(data)
  find_title(objectified_data)
end

def make_title_hash(array)
  # this method takes in an array of post-title-strings
  # it uses regex to separate post-title into song title and artist
  # returns a hash in "artist: title" format
  title_hash
  array.each do |post_title|

  end
end



execute_everything(data_from_reddit)
