# Rooftop
A mixin for ruby classes to access the rooftop cms rest api: http://www.rooftopcms.com

# Setup

## Installation

You can either install using [bundler](http://bundler.io) or just from the command line.

### Bundler
Include this in your gemfile

`gem 'rooftop'`

That's it! this is in active development so you might prefer:

`gem 'rooftop', github: "rooftop/rooftop-ruby"`
 
### Using Gem
As simple as:

`gem install rooftop`

## Configuration
You need to configure rooftop with a block, like this

```
    Rooftop.configure do |config|
        config.url = "http://yoursite.rooftopcms.io"
        config.api_token = "your token"
        config.api_path = "/wp-json/wp/v2/"
        config.user_agent = "rooftop cms ruby client #{rooftop::version} (http://github.com/rooftopcms/rooftop-ruby)"
        config.extra_headers = {custom_header: "foo", another_custom_header: "bar"}
        config.advanced_options = {} #for future use
    end
```

The minimum options you need to include are `url` and `api_token`.

# Use
Create a class in your application, and mix in some (or all) of the rooftop modules to interact with your remote content.

## Rooftop::Post
The Rooftop::Post mixin lets you specify a post type, so the api differentiates between types. if you don't set a post type, it defaults to posts.

```
class MyCustomPostType
    include Rooftop::Post
    self.post_type = "my_custom_post_type" #this is the singular post type name in WordPress
end
```
## Rooftop::Page
The rooftop::page mixin identifies this class as a page.
```
class Page
    include Rooftop::Page
end
```

## Custom endpoints and WordPress namespaces
If you write a wordpress api plugin, you can either expose your data in an existing `/wp/` namespace, or in a custom namespace.

rooftop includes `wp-api-menus`, so this gem supports the ability to specify an arbitrary namespace, version and endpoint name if necessary.

this example would return a collection of `mything` objects from the path `/wp-json/my-things/v3/things`:

```
class MyThing
    include rooftop::base
    self.api_namespace = "my-things"
    self.api_version = 3
    self.api_endpoint = "things"
end
```

If you don't specify the `api_endpoint` attribute, it assumes the underscored, pluralized version of the class name (`my_things` in this case)


## Field coercions
Sometimes you want to do something with a field after it's returned. for example, it would be useful to parse date strings to datetime.

To coerce one or more fields, call a class method in your class and pass a lambda which is called on the field.

```
class MyCustomPostType
    include rooftop::post
    self.post_type = "my_custom_post_type"
    coerce_field date: ->(date) { datetime.parse(date)}
end
    
```

### Object dates are coerced automatically
The created date field is coerced to a datetime. it's also aliased to `created_at`

The modification date is also coerced to a datetime. it's also aliased to `updated_at`

## Field aliases
Sometimes you might want to alias field names - for example, `date` is aliased to `created_at` to make it more rubyish. `modified` is also `updated_at`.
 
Creating alises and coercing them is order-sensitive. if you need to both coerce a field *and* alias it, do the coercion first. otherwise you'll find the aliased field isn't coerced.

(We don't just called `alias_method` on the original field because the object methods are dynamically generated from the returned data)

```
class mycustomposttype
    include rooftop::post
    self.post_type = "my_custom_post_type"
    coerce_field some_date: ->(date) { datetime.parse(date)}
    alias_field some_date: :another_name_for_some_date
end
```

## Resource links
*Resource links are a work-in-progress*

The Wordpress api uses the concept of hypermedia links (see http://v2.wp-api.org/extending/linking/ for more info). we parse the `_links` field in the response and build a Rooftop::ResourceLinks::Collection (which is a subclass of `array`). the individual links are instances of Rooftop::ResourceLinks::Link.

The reason for these classes is because we can do useful stuff with them, for example call `.resolve()` on a link to get an instance of the class to which it refers.

### Custom Link Relations
according to the wordpress api docs (and iana link relation convention) you need a custom name for link relations which don't fall into a [small subset of names](http://www.iana.org/assignments/link-relations/link-relations.xhtml). for those aren't in this list, we're prefixing the relation names with http://docs.rooftopcms.com/link_relations, which will resolve to some documentation.

### Nested Resource Links
rooftop uses the custom link relations to return a list of ancestors and children (not all descendants) in `_links`. rooftop::post and rooftop::page include rooftop::nested, which has some utility methods to access them.
 
```
class Page
    include rooftop::page
end

p = Page.first
p.ancestors #returns a collection of rooftop::resourcelinks::link items where `link_type` is "http://docs.rooftopcms.com/link_relations/ancestors"
p.children #returns a collection of rooftop::resourcelinks::link items where `link_type` is "http://docs.rooftopcms.com/link_relations/children"
p.parent #returns the parent entity
```
## Handling Content Fields
Rooftop can return a variable number of content fields depending on what you've configured in advanced custom fields.

The raw data is available in your object at `.content`:

```
p = Page.first
p.content #returns a hash of content data
```
But that's not super-helpful, so the gem generates a collection for you.

```
p = Page.first
p.fields #a Rooftop::Content::Collection, containing Rooftop::Content::Field entries.
```

You can access a particular piece of content like this:

```
p = Page.first
p.fields.your_field #your_field would be a custom field you've created in Advanced Custom Fields
p.fields.content #the default 'content' field from the Rooftop admin interface
```

You can get a list of all the fields on your model like this:

```
p = Page.first
p.fields.field_names #returns an array of field names you can call
```


## SSL / TLS
Hosted Rooftop from rooftopcms.io exclusively uses ssl/tls. you need to configure the rooftop library to use ssl.
 
This library uses the excellent [her rest client](https://github.com/remiprev/her) which in turn uses [faraday](https://github.com/lostisland/faraday/) for http requests. the [faraday ssl docs](https://github.com/lostisland/faraday/wiki/setting-up-ssl-certificates) are pretty complete, and the ssl options are exposed straight through this library:

```
Rooftop.configure do |config|
    # other config options
    config.ssl_options = {
        #your ssl options in here.
    }
    # other config options
end
```

Leaving `config.ssl_options` unset allows you to work without https.

## Caching
While hosted rooftop is cached at source and delivered through a cdn, caching locally is a smart idea. the rooftop library uses the [faraday-http-cache](https://github.com/plataformatec/faraday-http-cache) to intelligently cache responses from the api. rooftop updates etags when entities are updated so caches shouldn't be stale.

_(the cache headers plugin for rooftop is a work in progress)_
 
 If you want to cache responses, set `perform_caching` to true in your configuration block. you will need to provide a cache store and logger in the `cache_store` and `cache_logger` config options. by default, the cache store is set to `activesupport::cache.lookup_store(:memory_store)` which is a sensible default, but isn't shared across threads. any activesupport-compatible cache store (memcache, file, redis etc.) will do.
   
 The `cache_logger` option determines where cache debug messages (hits, misses etc.) get stored. by default it's `nil`, which switches logging off.
 
 ## Menus
 WordPress comes with quite a powerful way to build menus, rather than needing to traverse a tree of objects directly.
 
 ### Accessing the menu you need
 At the moment you have to know the ID of the menu you need - not ideal. Keep an eye on the following issues to get an update:
 
 * https://github.com/rooftopcms/rooftop-custom-content-setup/issues/3
 * https://github.com/rooftopcms/rooftop-custom-content-setup/issues/4
 
 So for now, with that in mind, here's how you do it:
 
 ```
 r = Rooftop::Menus::Menu.find(2) #returns a menu with ID 2
 r.items # a collection of Rooftop::Menus::Item
 ```
 
 ### Accessing the object to which a menu item refers
 If a menu item refers to an object in Rooftop - a post or a page - you can access the original object by calling `object()`.
  
 ```
r = Rooftop::Menus::Menu.find(2) #returns a menu with ID 2
r.items # a collection of Rooftop::Menus::Item
item = r.items.first # a Rooftop::Menus::Item
item.object # an object derived from the post type and ID. 
 ```
 
 If you haven't defined a class for a post type, you'll get a `Rooftop::Menus::UnmappedObjectError`
 
 
# Roadmap
Lots! here's a flavour:

## Reading data

* preview mode. rooftop supports passing a preview header to see content in draft. we'll expose that in the rooftop gem as a constant.
* taxonomies will be supported and side-loaded against content
* media: media is exposed by the api, and should be accessible and downloadable.

## Writing
If your api user in rooftop has permission to write data, the api will allow it, and so should this gem. at the moment all the code is theoretically in place but untested. it would be great to have [issues raised](https://github.com/rooftopcms/rooftop-ruby/issues) about writing back to the api.

Some abstractions will definitely need putting back into a hash to save.

# Contributing
rooftop and its libraries are open-source and we'd love your input.

1. fork the repo on github
2.  make whatever changes / extensions you think would be useful
3. if you've got lots of commits, rebase them into sensible squashed chunks
4. raise a pr on the project

if you have a real desire to get involved, we're looking for maintainers. [let us know!](mailto: hello@rooftopcms.com).


# Licence
`rooftop-ruby` is a library to allow you to connect to Rooftop CMS, the API-first WordPress CMS for developers and content creators.

Copyright 2015 Error Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the gnu general public license as published by
the free software foundation, either version 3 of the license, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.  see the
gnu general public license for more details.

You should have received a copy of the GNU general public license
along with this program.  if not, see <http://www.gnu.org/licenses/>.



