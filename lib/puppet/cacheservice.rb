#=====================================
#This class will provide methods to 
# deal with Cache service to cache 
# Session keys , tokens which are required
# in REST API calls in Pure Storage Array.
#  
#
# Supports REST API 1.6
#=====================================

require 'tmpdir'

class CacheService
  
  CACHE_EXPIRY      = 25 # in minutes
  
  #------------------------------------------------------------------------------------
  # Get the OS specific temp dir location
  # Cache data will be stored in /tmp/<NodeName> file.
  #------------------------------------------------------------------------------------
  def getOsTmpDir
    tmpFileName = Dir.tmpdir()
    Puppet.debug("@@@@ OS specific tmp file path is : "+ tmpFileName)
    return tmpFileName
  end
  
  #------------------------------------------------------------------------------------
  # Constructor
  #------------------------------------------------------------------------------------
  def initialize (cache_file_name)
    @cache_file_name = getOsTmpDir() + "/"+ cache_file_name
    Puppet.debug("@@@@ Cache file path is : "+ @cache_file_name)
  end 
    
    #------------------------------------------------------------------------------------
    # Below method will check if cache file is expired by comparing it with CACHE_EXPIRY
    #------------------------------------------------------------------------------------
    def isCacheExpired
      if(File.exist?(@cache_file_name))
        file_create_time = File.mtime(@cache_file_name)
        current_time = Time.now
        #Find out time difference in minutes
        time_difference =  (current_time-file_create_time)/60
        #puts time_difference 
        #Expiry is 25 minutes
        return true if(time_difference > CACHE_EXPIRY)
      end
      return false
    end 
    
    #------------------------------------------------------------------------------------
    # Below method will cache properties like token, session
    # This method will save or updates key,value in <DEVICENAME> file
    #------------------------------------------------------------------------------------
    def writeCache (key,value)
      begin
        aFile = File.new(@cache_file_name, "a+")
        aFile.puts(key+":"+value)
        aFile.close
      rescue
        #puts "File '"+ @cache_file_name +"' not found or some other exception in writeCache()!!!"
        Puppet.debug("File '"+ @cache_file_name +"' not found or some other exception in writeCache()!!!")
        return nil 
      end
    end
    
    #------------------------------------------------------------------------------------
    # Below method will return cache properties like token, session from <DEVICENAME> file
    #------------------------------------------------------------------------------------
    def readCache(key)
      begin
        lines = File.readlines(@cache_file_name)
        line_num=0
        while line_num < lines.size do
          if(lines[line_num]!= nil and lines[line_num].strip.index(key)==0 and lines[line_num].strip.include? key)
            #puts "Key " + key + " is found!!!"
            Puppet.debug("Key " + key + " is found!!!")
            value = lines[line_num].strip.split(":")[1]
            return value  
          end   
          line_num = + 1
        end
        return nil
      rescue
        #puts "File '"+ @cache_file_name +"' not found or key not found in cache readCache()!!!"
        Puppet.debug("File '"+ @cache_file_name +"' not found or key not found in cache readCache()!!!")
        return nil 
      end
    end
    
    #------------------------------------------------------------------------------------
    # Below method will delete <DEVICENAME> file if it exists
    #------------------------------------------------------------------------------------
    def deleteCache
      begin 
        File.delete(@cache_file_name) if File::exist?(@cache_file_name)
        #puts "File '"+ @cache_file_name +"' deleted successfully!!!"
        Puppet.debug("File '"+ @cache_file_name +"' deleted successfully!!!")
      rescue
        #puts "File '"+ @cache_file_name +"' not found or some other exception in deleteCache()!!!"
        Puppet.debug("File '"+ @cache_file_name +"' not found or some other exception in deleteCache()!!!")
        return nil 
      end  
    end
end
