require 'fileutils'

module SpreeProductsImporter
  module Generators
    class InstallGenerator < Rails::Generators::Base

      class_option :auto_run_migrations, :type => :boolean, :default => false
      source_root File.expand_path('../../../../templates', __FILE__)

      def add_javascripts
        append_file 'app/assets/javascripts/store/all.js', "//= require store/spree_products_importer\n"
        append_file 'app/assets/javascripts/admin/all.js', "//= require admin/spree_products_importer\n"
      end

      def add_stylesheets
        inject_into_file 'app/assets/stylesheets/store/all.css', " *= require store/spree_products_importer\n", :before => /\*\//, :verbose => true
        inject_into_file 'app/assets/stylesheets/admin/all.css', " *= require admin/spree_products_importer\n", :before => /\*\//, :verbose => true
      end

      def files
        copy_file('example.xls', 'lib/templates/example.xls')
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_products_importer'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
