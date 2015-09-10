# RooftopRubyClient
A mixin for Ruby classes to access the Wordpress REST API (http://wp-api.org)

# Setup

## Configuration
You need to configure RooftopRubyClient with a block, like this

```
    RooftopRubyClient.configure do |config|
        config.url = "http://your.rooftop-cms.site/wp-json"
    end
```

# Use
Create a class and use one of the mixins to get the data.

## RooftopRubyClient::Post
The RooftopRubyClient::Post mixin lets you specify a post type, so the API differentiates between types.

```
class MyCustomPostType
    include RooftopRubyClient::Post
    self.post_type = "my_custom_post_type" #this is the post type name in Wordpress
end
```
## RooftopRubyClient::Page
The RooftopRubyClient::Page mixin identifies this class as a page.
```
class Page
    include RooftopRubyClient::Page
end
```

## Field coercions
Sometimes you want to do something with a field after it's returned. For example, it would be useful to parse date strings to DateTime.

To coerce one or more fields, call a class method in your class and pass a lambda which is called on the field.

```
class MyCustomPostType
    include RooftopRubyClient::Post
    self.post_type = "my_custom_post_type"
    coerce_field date: ->(date) { DateTime.parse(date)}
```

There are some coercions done manually.

### Author
When an object is returned from the API, the Author information is automatically parsed into a RooftopRubyClient::Author object.

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
* Allowing other classes to be exposed: mixing in RooftopRubyClient::Client *should* allow a custom class to hit the right endpoint, but it's work-in-progress



