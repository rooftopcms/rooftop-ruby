# Rooftop
A mixin for Ruby classes to access the Wordpress REST API (http://wp-api.org)

# Setup

## Configuration
You need to configure Rooftop with a block, like this

```
    Rooftop.configure do |config|
        config.url = "http://your.rooftop-cms.site/wp-json"
    end
```

# Use
Create a class and use one of the mixins to get the data.

## Rooftop::Post
The Rooftop::Post mixin lets you specify a post type, so the API differentiates between types.

```
class MyCustomPostType
    include Rooftop::Post
    self.post_type = "my_custom_post_type" #this is the post type name in Wordpress
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
```

There are some coercions done manually.

### Author
When an object is returned from the API, the Author information is automatically parsed into a Rooftop::Author object.

### Date
Created date is coerced to a DateTime. It's also aliased to created_at

### Modified
The modification date is coerced to a DateTime. It's also aliased to updated_at

# To do
Lots! Here's a flavour:

* Taxonomies need to be supported (http://wp-api.org/#taxonomies_retrieve-all-taxonomies)
* Authentication: there are a couple of ways of doing this, but the simplest would be a quick WP plugin to generate a per-user API key which we pass in the header.
* Preview: once authentication is solved, we need to be able to show posts in draft
* Media: media is exposed by the API. Don't know if this explicitly needs supporting by the API or just accessible
* Allowing other classes to be exposed: mixing in Rooftop::Client *should* allow a custom class to hit the right endpoint, but it's work-in-progress

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



