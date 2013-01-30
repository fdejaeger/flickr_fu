# wrapping class to hold an flickr photo
# 
class Flickr::People::Person
  attr_accessor :username, :nsid, :is_admin, :is_pro, :icon_server, :icon_farm, :realname, :mbox_sha1sum, :location, :photos_url, :profile_url, :photo_count, :photo_first_upload, :photo_first_taken
    
  # create a new instance of a flickr person.
  # 
  # Params
  # * flickr (Required)
  #     the flickr object
  # * attributes (Required)
  #     a hash of attributes used to set the initial values of the person object
  def initialize(flickr, attributes)
    @flickr = flickr
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
  
  def buddy_icon
    @buddy_icon ||= if icon_server.to_i > 0
                      "http://farm#{icon_farm}.static.flickr.com/#{icon_server}/buddyicons/#{nsid}.jpg"
                    else
                      'http://www.flickr.com/images/buddyicon.jpg'
                    end
  end
  
  # Get a list of public photos for the given user.
  # 
  # Options
  # * safe_search (Optional)
  #     Safe search setting:
  #       1 for safe.
  #       2 for moderate.
  #       3 for restricted.
  #     (Please note: Un-authed calls can only see Safe content.)
  # * per_page (Optional)
  #     Number of photos to return per page. If this argument is omitted, it defaults to 100. The maximum allowed value is 500.
  # * page (Optional)
  #     The page of results to return. If this argument is omitted, it defaults to 1.
  def public_photos(options = {})
    options.merge!({:user_id => self.nsid, :extras => "license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo,tags,machine_tags,o_dims,views,media"})

    rsp = @flickr.send_request('flickr.people.getPublicPhotos', options)

    returning Flickr::Photos::PhotoResponse.new(:page => rsp.photos[:page].to_i,
                                :pages => rsp.photos[:pages].to_i,
                                :per_page => rsp.photos[:perpage].to_i,
                                :total => rsp.photos[:total].to_i,
                                :photos => [],
                                :api => self,
                                :method => 'public_photos',
                                :options => options) do |photos|
      rsp.photos.xpath("photo").each do |photo|
        attributes = Flickr::Photos.create_attributes(photo)
        photos << Flickr::Photos::Photo.new(@flickr, attributes)
      end if rsp.photos.at_xpath("photo")
    end
  end
end