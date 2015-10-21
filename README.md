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

# Roadmap
## Reading data
Lots! Here's a flavour:

* Preview mode. Rooftop supports passing a preview header to see content in draft. We'll expose that in the rooftop gem as a constant.
* Taxonomies will be supported and side-loaded against content
* Menus are exposed by Rooftop. We need to create a Rooftop::Menu mixin
* Hypermedia links need to resolve to the right place. At the moment calling `.links` on an object returns a Rooftop::ResourceLinks::Collection which is a good start. 
* Media: media is exposed by the API, and should be accessible and downloadable.

## Writing Data
If your API user in Rooftop has permission to write data, the API will allow it, and so should this gem. At the moment all the code is theoretically in place but untested.

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



