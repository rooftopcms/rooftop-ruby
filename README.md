# Rooftop
A mixin for Ruby classes to access the Rooftop CMS REST API: http://www.rooftopcms.com

# Setup

## Installation

You can either install using [Bundler](http://bundler.io) or just from the command line.

### Bundler
Include this in your gemfile

`gem 'rooftop'`

That's it! This is in active development so you might prefer:

`gem 'rooftop', github: "rooftop/rooftop-ruby"`
 
### Using Gem
As simple as:

`gem install rooftop`

## Configuration
You need to configure Rooftop with a block, like this

```
    Rooftop.configure do |config|
        config.url = "http://yoursite.rooftopcms.io"
        config.api_token = "your token"
        config.api_path = "/wp-json/wp/v2/"
        config.user_agent = "Rooftop CMS Ruby client #{Rooftop::VERSION} (http://github.com/rooftopcms/rooftop-ruby)"
        config.extra_headers = {custom_header: "foo", another_custom_header: "bar"}
        config.advanced_options = {} #for future use
    end
```

The minimum options you need to include are `url` and `api_token`.

# Use
Create a class in your application, and mix in some (or all) of the rooftop modules to interact with your remote content.

## Rooftop::Post
The Rooftop::Post mixin lets you specify a post type, so the API differentiates between types. If you don't set a post type, it defaults to posts.

```
class MyCustomPostType
    include Rooftop::Post
    self.post_type = "my_custom_post_type" #this is the singular post type name in Wordpress
end
```
## Rooftop::Page
The Rooftop::Page mixin identifies this class as a page.
```
class Page
    include Rooftop::Page
end
```

## Field coercions
Sometimes you want to do something with a field after it's returned. For example, it would be useful to parse date strings to DateTime.

To coerce one or more fields, call a class method in your class and pass a lambda which is called on the field.

```
class MyCustomPostType
    include Rooftop::Post
    self.post_type = "my_custom_post_type"
    coerce_field date: ->(date) { DateTime.parse(date)}
end
    
```

### Object dates are coerced automatically
The created date field is coerced to a DateTime. It's also aliased to `created_at`

The modification date is also coerced to a DateTime. It's also aliased to `updated_at`

## Field aliases
Sometimes you might want to alias field names - for example, `date` is aliased to `created_at` to make it more rubyish. `modified` is also `updated_at`.
 
Creating alises and coercing them is order-sensitive. If you need to both coerce a field *and* alias it, do the coercion first. Otherwise you'll find the aliased field isn't coerced.

(We don't just called `alias_method` on the original field because the object methods are dynamically generated from the returned data)

```
class MyCustomPostType
    include Rooftop::Post
    self.post_type = "my_custom_post_type"
    coerce_field some_date: ->(date) { DateTime.parse(date)}
    alias_field some_date: :another_name_for_some_date
end
```

## Resource Links
* Resource Links are a work-in-progress*

The WordPress API uses the concept of Hypermedia Links (see http://v2.wp-api.org/extending/linking/ for more info). We parse the `_links` field in the response and build a Rooftop::ResourceLinks::Collection (which is a subclass of `Array`). The individual links are instances of Rooftop::ResourceLinks::Link.

The reason for these classes is because we can do useful stuff with them, for example call `.resolve()` on a link to get an instance of the class to which it refers.

### Custom Link Relations
According to the WordPress API docs (and IANA link relation convention) you need a custom name for link relations which don't fall into a [small subset of names](http://www.iana.org/assignments/link-relations/link-relations.xhtml). For those aren't in this list, we're prefixing the relation names with http://docs.rooftopcms.com/link_relations, which will resolve to some documentation.

### Nested Resource Links
Rooftop uses the custom link relations to return a list of ancestors and children (not all descendants) in `_links`. Rooftop::Post and Rooftop::Page include Rooftop::Nested, which has some utility methods to access them.
 
```
class Page
    include Rooftop::Page
end

p = Page.first
p.ancestors #returns a collection of Rooftop::ResourceLinks::Link items where `link_type` is "http://docs.rooftopcms.com/link_relations/ancestors"
p.children #returns a collection of Rooftop::ResourceLinks::Link items where `link_type` is "http://docs.rooftopcms.com/link_relations/children"
p.parent #returns the parent entity
```

## SSL / TLS
Hosted Rooftop from rooftopcms.io exclusively uses SSL/TLS. You need to configure the Rooftop library to use SSL.
 
This library uses the excellent [Her REST Client](https://github.com/remiprev/her) which in turn uses [Faraday](https://github.com/lostisland/faraday/) for http requests. The [Faraday SSL docs](https://github.com/lostisland/faraday/wiki/Setting-up-SSL-certificates) are pretty complete, and the SSL options are exposed straight through this library:

```
Rooftop.configure do |config|
    # other config options
    config.ssl_options = {
        #your ssl options in here.
    }
    # other config options
end
```

Leaving `config.ssl_options` unset allows you to work without HTTPS.

## Caching
While hosted Rooftop is cached at source and delivered through a CDN, caching locally is a smart idea. The Rooftop library uses the [faraday-http-cache](https://github.com/plataformatec/faraday-http-cache) to intelligently cache responses from the API. Rooftop updates etags when entities are updated so caches shouldn't be stale.

_(The cache headers plugin for Rooftop is a work in progress)_
 
 If you want to cache responses, set `perform_caching` to true in your configuration block. You will need to provide a cache store and logger in the `cache_store` and `cache_logger` config options. By default, the cache store is set to `ActiveSupport::Cache.lookup_store(:memory_store)` which is a sensible default, but isn't shared across threads. Any ActiveSupport-compatible cache store (Memcache, file, Redis etc.) will do.
   
 The `cache_logger` option determines where cache debug messages (hits, misses etc.) get stored. By default it's `nil`, which switches logging off.

# Roadmap
## Reading data
Lots! Here's a flavour:

* Preview mode. Rooftop supports passing a preview header to see content in draft. We'll expose that in the rooftop gem as a constant.
* Taxonomies will be supported and side-loaded against content
* Menus are exposed by Rooftop. We need to create a Rooftop::Menu mixin 
* Media: media is exposed by the API, and should be accessible and downloadable.

## Writing Data
If your API user in Rooftop has permission to write data, the API will allow it, and so should this gem. At the moment all the code is theoretically in place but untested. It would be great to have [issues raised](https://github.com/rooftopcms/rooftop-ruby/issues) about writing back to the API.

# Contributing
Rooftop and its libraries are open-source and we'd love your input.

1. Fork the repo on github
2.  Make whatever changes / extensions you think would be useful
3. If you've got lots of commits, rebase them into sensible squashed chunks
4. Raise a PR on the project

If you have a real desire to get involved, we're looking for maintainers. [Let us know!](mailto: hello@rooftopcms.com).


# Licence
Rooftop Ruby is a library to allow you to connect to Rooftop CMS, the API-first WordPress CMS for developers and content creators.

Copyright 2015 Error Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.



