require 'rubygems'
require 'sequel'

#
# Store everything in memory for dummy apps
#
DB = Sequel.sqlite
Sequel::Model.plugin :timestamps, update_on_create: true

#
# Should split this out but will do for now
#
DB.create_table :links do
  primary_key :id

  column :original_link, :text, unique: true
  column :code, :text, unique: true
  column :used, Integer, default: 0
  column :created_at, DateTime
  column :updated_at, DateTime

  index :id
end

#
# Should be namespaced but won't worry about it here
#
class Link < Sequel::Model
  #
  # Do not use uppercase because it makes it harder to tell it
  # to someone else in conversation, e.g. over the phone.
  #
  ALPHABET = "abcdefghijklmnopqrstuvwxyz0123456789".split(//)

  plugin :validation_helpers

  def validate
    super

    validates_presence [:original_link]
    validates_format /\Ahttps?:\/\/.*/, :original_link, :message=>'is not a valid URL'
    validates_unique :original_link, :code
  end

  def before_create
    self.code = unique_code
  end

  def increase_used_count
    self.used = self.used + 1
    save
  end

  private

  def unique_code
    unique_code = random_code

    unique_code until Link.where(code: unique_code).first.nil?

    unique_code
  end

  def random_code
    [*('a'..'z'), *(0..9)].shuffle[0, 6].join
  end

  #
  # From https://gist.github.com/zumbojo/1073996
  #
  def bijective_encode(i)
    # from http://refactormycode.com/codes/125-base-62-encoding
    # with only minor modification
    return ALPHABET[0] if i == 0
    s = ''
    base = ALPHABET.length
    while i > 0
      s << ALPHABET[i.modulo(base)]
      i /= base
    end
    s.reverse
  end

  def bijective_decode(s)
    # based on base2dec() in Tcl translation
    # at http://rosettacode.org/wiki/Non-decimal_radices/Convert#Ruby
    i = 0
    base = ALPHABET.length
    s.each_char { |c| i = i * base + ALPHABET.index(c) }
    i
  end
end
