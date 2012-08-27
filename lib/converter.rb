require 'rubygems'
require 'redis'

r = Redis.new

keys = r.keys("ais.vessel.*")
keys.each do |k|
  vessel = r.get(k)
  key, mmsi, type, name = vessel.split(',')
  r.set(k, "#{key},#{mmsi},0000000000.000000000,#{type},#{name}")
end
