require "mobility/backends/active_record"
require "mobility/backends/column"

module Mobility
  module Backends
=begin

Implements the {Mobility::Backends::Column} backend for ActiveRecord models.

You can use the +mobility:translations+ generator to create a migration adding
translatable columns to the model table with:

  rails generate mobility:translations post title:string

The generated migration will add columns +title_<locale>+ for every locale in
+I18n.available_locales+. (The generator can be run again to add new attributes
or locales.)

@example
  class Post < ActiveRecord::Base
    translates :title, backend: :column
  end

  Mobility.locale = :en
  post = Post.create(title: "foo")
  post.title
  #=> "foo"
  post.title_en
  #=> "foo"
=end
    class ActiveRecord::Column
      include ActiveRecord
      include Column

      require 'mobility/backends/active_record/column/query_methods'

      # @!group Backend Accessors
      # @!macro backend_reader
      def read(locale, _ = {})
        model.read_attribute(column(locale))
      end

      # @!macro backend_writer
      def write(locale, value, _ = {})
        model.send(:write_attribute, column(locale), value)
      end
      # @!endgroup

      # @!macro backend_iterator
      def each
        available_locales.each { |l| yield(l) if present?(l) }
      end

      setup_query_methods(QueryMethods)

      private

      def available_locales
        @available_locales ||= get_column_locales
      end

      def get_column_locales
        column_name_regex = /\A#{attribute}_([a-z]{2}(_[a-z]{2})?)\z/.freeze
        model.class.columns.map do |c|
          (match = c.name.match(column_name_regex)) && match[1].to_sym
        end.compact
      end
    end
  end
end