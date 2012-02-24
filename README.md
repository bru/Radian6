# Radian6

Radian6 gem is a (rough) ruby interface to the Radian6 EST API (http://labs.radian6.com/api/)

## INSTALLATION

    gem install radian6

## Usage

    # connect to the API
    api = Radian6::API.new(username, password, app_key, :sandbox =>
true, :proxy => myproxy, :debug => true, :async => false)
    
    # get a XML dump of the posts within a specified range
    posts_xml = api.fetchRangeTopicPostsXML( ((Time.now - 3600)*1000).to_s, (Time.now * 1000).to_s, [topic])

    # get topics
    topics = api.topics
    


## Status

This is just the first draft of the wrapper. It can be improved in many, many ways.
The API class in particular is quite messy, as it's the result of several experiments, expect it to change quite dramatically in the near future. 

Feel free to help (see Contributing below)

## TODO

* Clean up API class (maybe structuring the various calls in different "services" as suggested by the API documentation)
* better coverage for object output (right now only Post and Topic are supported)
* remove the option to generate objects from xml as it's too slow and hogs the memory when dealing with big pages.
* remove async connection option and isolate it via a Connector class interface

## Contributing to the code (a.k.a. submitting a pull request)

1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Commit and push your changes.
5. Submit a pull request. Please do not include changes to the gemspec, version, or history file. (If you want to create your own version for some reason, please do so in a separate commit.)


## Copyright

Copyright (c) 2012 Riccardo Cambiassi. See LICENSE for details.
