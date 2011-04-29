class Home < ActiveRecord::Base
  validates_uniqueness_of :ublog_name
  validates_format_of :ublog_name, :with => /\A[^ $~!@#%^&*+=(){};':",?<>.]*\Z/, :message => " cannot have blanks or punctuation. Remove them. Check for trailing blanks."
  validates_presence_of :owner
  validates_presence_of :name
  validates_format_of :email_list, :with => /\A[^ $~!@#%^&*+=(){};':",?<>.]*\Z/, :message => " cannot have @ or blanks or punctuation. Remove them. Check for trailing blanks."
  
  has_one :asset # photo of owner
  
  has_many :blogs # as "owner" of those blogs
  has_many :responses, :class_name => "Blog", :foreign_key => "to_id" # blogs "to" this owner
  has_many :friends # as the "origin" of the friendship
  has_many :friend_homes, :through => :friends # refer back to homes
  has_many :followers, :class_name => "Friend", :foreign_key => "friend_id" # "friend_home" matches
  has_many :follower_homes, :through => :followers, :source => :origin # refer back to homes
  has_many :tagsubs
  has_many :tags, :through => :tagsubs
  has_many :groups, :through => :friends, :source => :friend_home, :conditions => "is_group = 1"
  
  # email subscriptions; subset of friend_homes and tags
  has_many :email_friends, :class_name => "Friend", :foreign_key => "home_id", :conditions => "email_notify > 0"
  has_many :email_friend_homes, :through => :email_friends, :source => :friend_home
  has_many :email_tagsubs, :class_name => "Tagsub", :foreign_key => "home_id", :conditions => "email_notify > 0"
  has_many :email_tags, :through => :email_tagsubs, :source => :tag
  
  acts_as_solr :fields => [:ublog_name, :name]
  
  def private_subs
    friend_homes.map do |home|
      home if home.is_private && (home.is_private == 1)
    end
  end
end
