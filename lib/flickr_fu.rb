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

module Flickr

  if RUBY_VERSION =~ /1.8/
  # Credit to Jim Weirich at http://onestepback.org/index.cgi/Tech/Ruby/BlankSlate.rdoc
    class BlankSlate
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    end
  else
    BlankSlate = BasicObject
  end

  # Class that makes accessing xml objects more like any other ruby object
  # thanks to the magic of method missing
  class XmlMagic < BlankSlate
    require 'rexml/document'
    
    def initialize(xml, namespace="")
      if xml.class == ::REXML::Element or xml.class == ::Array
        @element = xml
      else
        @xml = ::REXML::Document.new(xml)
        @element = @xml.root
      end
      @namespace = namespace
    end

    def each
      @element.each {|e| yield ::Flickr::XmlMagic.new(e, @namespace)}
    end

    def method_missing(method, selection=nil)
      evaluate(method.to_s, selection)
    end

    def namespace=(namespace)
      if namespace and namespace.length > 0 # caca
        @namespace = namespace + ":"
      else
        @namespace = ""
      end
    end
    
    def to_s
      if @element.class == ::Array
        @element.collect{|e| e.text}.join
      else
        @element.text
      end
    end

    def [](index, count = nil)
      if index.is_a?(::Fixnum) or index.is_a?(::Bignum) or index.is_a?(::Integer) or index.is_a?(::Range) 
        if @element.is_a?(::Array)
          if count
            ::Flickr::XmlMagic.new(@element[index, count], @namespace)
          else
            ::Flickr::XmlMagic.new(@element[index], @namespace)
          end
        else
          nil
        end
      elsif index.is_a?(::Symbol)
        if @element.is_a?(::Array)
          if @element.empty?
            nil
          else
            @element[0].attributes[index.to_s]
          end
        else
          @element.attributes[index.to_s]
        end
      end
    end

    private
    def evaluate(name, selection)
      
      if @element.is_a?(::Array)
        elements = @element[0].get_elements(@namespace + name)
      else
        elements = @element.get_elements(@namespace + name)
      end
      
      if elements.empty?
        nil
      else
        if selection == :count
          elements.length
        else
          ::Flickr::XmlMagic.new(elements, @namespace)
        end
      end
    end
  end
end  # module Flickr


class Object
  # returning allows you to pass an object to a block that you can manipulate returning the manipulated object
  def returning(value)
    yield(value)
    value
  end
end
