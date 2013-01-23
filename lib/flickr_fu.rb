require 'rubygems'
require 'net/http'
require 'cgi'
require 'uri'
require 'open-uri'
require 'mime/types'
require 'digest/md5'
require 'yaml'
require 'time'
require 'date'

# base must load first
[ "base",
  "test",
  "auth",
  "token",
  "photos",
  "photo",
  "photo_response",
  "photosets",
  "photoset",
  "comment",
  "note",
  "size",
  "uploader",
  "status",
  "people",
  "person",
  "license",
  "errors",
  "contacts",
  "contact",
  "geo",
  "location",
  "urls" ].each do |file|
  require File.join(File.dirname(__FILE__), 'flickr', file)
end



class Object
  # returning allows you to pass an object to a block that you can manipulate returning the manipulated object
  def returning(value)
    yield(value)
    value
  end
end
