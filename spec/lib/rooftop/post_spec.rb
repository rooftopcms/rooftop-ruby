require 'spec_helper'

class Post
    include Rooftop::Post
end

Rooftop.configure do |config|
    config.url = "http://rooftop.rooftop-cms.dev"
    config.api_token = "e266fbdd1464980e8b9069b3fe3f71cd"
    config.api_path = "/wp-json"
    config.user_agent = "rooftop cms ruby client (http://github.com/rooftopcms/rooftop-ruby)"
end

describe Post do
    context "Fetching posts" do
        subject(:post) {Post.find(1)}

        it "should return a post object" do
            expect(post.id).to equal(1)
        end

        it "should have a link object attribute" do
            expect(post.link.respond_to?(:keys)).to equal(true)
        end

        it "should have basic content" do
            expect(post.content.keys.include?("basic")).to equal(true)
        end

        it "should have advanced content" do
            expect(post.content.keys.include?("advanced")).to equal(true)
        end
    end

    context "Saving posts" do
        subject(:post) {Post.find(1)}

        it "should update the post title" do
            original_title = post.title
            post.title = "Test #{rand}"
            post.save

            updated_post = Post.find(1)

            expect(updated_post.title).not_to equal(original_title)

            # restore the post title
            post.title = original_title
            post.save
        end
    end
end
