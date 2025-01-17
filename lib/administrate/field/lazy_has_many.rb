require 'administrate/field/has_many'
require 'administrate/field/lazy_has_many/version'
require 'rails/engine'
require 'administrate/engine'

module Administrate
  module Field
    class LazyHasMany < Administrate::Field::HasMany
      include LazyHasManyVersion

      class Engine < ::Rails::Engine
      end

      def candidate_resources
        if options.key?(:includes)
          includes = options.fetch(:includes)
          associated_class.includes(*includes).where(id: data.map(&:id))
        else
          associated_class.where(id: data.map(&:id))
        end
      end

      def custom_attribute_id
        "#{resource.class.name.underscore}_#{attribute_key}"
      end

      def to_s
        data.map { |v| display_candidate_resource(v) }
      end

      def action
        raise StandardError.new 'action is missing' if options[:action].blank?

        Rails.application.routes.url_helpers.send(options[:action])
      end

      def result_limit
        options[:result_limit] || 10
      end

      def order_from_params(params)
        Administrate::Order.new(
          params.fetch(:order, sort_by),
          params.fetch(:direction, direction),
        )
      end

      def associated_resource_options
        candidate_resources.map do |resource|
          [display_candidate_resource(resource), resource.send(primary_key)]
        end
      end

      def order
        @order ||= Administrate::Order.new(sort_by, direction)
      end


    end
  end
end
