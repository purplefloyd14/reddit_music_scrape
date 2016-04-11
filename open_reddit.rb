
require "open-uri"
require 'json'
require "tempfile"
require 'watir-webdriver'
require "phantomjs"
require "date"

# b = Watir::Browser.new :firefox
# b.goto 'www.anything2mp3.com'
# f = b.form(:id, "videoconverter-convert-form")
# b.text_field(:id, 'edit-url').set('https://www.youtube.com/watch?v=bQDcSkGWvfc&nohtml5=False')
# f.submit
# b.button(:class => 'success').wait_until_present
# b.button(:class => 'success').click
# puts b.title
# b.close

# exec "youtube-dl -x -ohttps://www.youtube.com/watch?v=MUINFs1Sp94"
## https://watirwebdriver.com/waiting/

data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=20")

month = Date::MONTHNAMES[Date.today.month]
p  month

def find_urls(thing)
  #this method iterates through the data for each post it is given
  #then it adds all of the titles from the data to an array and returns that array
  all_titles = []
  thing["data"]["children"].each do |post|
    all_titles << post["data"]["url"]
  end
  return all_titles
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


def execute_everything(month, data_from_reddit)
  make_dir(month) #create dir for month

  objectified_data = make_string(data_from_reddit) #make reddit data a string


  url_array = find_urls(objectified_data)
  #pass all results (now as string) to find_url method which returns array of urls only


  url_array.each do |url|
    run_download(url, month)
  end
  #iterates over url array and downloads file for each url, adding it to month directory

end


def make_dir(month)
  `mkdir #{month}`
end


def run_download(url, month)
  `youtube-dl -x -f 140 -o\'./#{month}/%(title)s.%(ext)s\' #{url}`
end




# run_download


#
#
execute_everything(month, data_from_reddit)
