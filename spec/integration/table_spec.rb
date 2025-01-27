# Copyright (c) 2011 - 2013, SoundCloud Ltd., Rany Keddo, Tobias Bielohlawek, Tobias
# Schmidt

require File.expand_path(File.dirname(__FILE__)) + '/integration_helper'
require 'lhm/table'

describe Lhm::Table do
  include IntegrationHelper

  describe 'id numeric column requirement' do
    describe 'when met' do
      before(:each) do
        connect_master!
        @table = table_create(:custom_primary_key)
      end

      it 'should parse primary key' do
        value(@table.pk).must_equal('pk')
      end

      it 'should parse indices' do
        value(@table.indices['index_custom_primary_key_on_id']).must_equal(['id'])
      end

      it 'should parse columns' do
        value(@table.columns['id'][:type]).must_match(/(bigint|int)\(\d+\)/)
      end

      it 'should return true for method that should be renamed' do
        value(@table.satisfies_id_column_requirement?).must_equal true
      end

      it 'should support bigint tables' do
        @table = table_create(:bigint_table)
        value(@table.satisfies_id_column_requirement?).must_equal true
      end
    end

    describe 'when not met' do
      before(:each) do
        connect_master!
      end

      it 'should return false for a non-int id column' do
        @table = table_create(:wo_id_int_column)
        value(@table.satisfies_id_column_requirement?).must_equal false
      end
    end
  end

  describe Lhm::Table::Parser do
    describe 'create table parsing' do
      before(:each) do
        connect_master!
        @table = table_create(:users)
      end

      it 'should parse table name in show create table' do
        value(@table.name).must_equal('users')
      end

      it 'should parse primary key' do
        value(@table.pk).must_equal('id')
      end

      it 'should parse column type in show create table' do
        value(@table.columns['username'][:type]).must_equal('varchar(255)')
      end

      it 'should parse column metadata' do
        assert_nil @table.columns['username'][:column_default]
      end

      it 'should parse indices' do
        value(@table.indices['index_users_on_username_and_created_at']).must_equal(['username', 'created_at'])
      end

      it 'should parse index' do
        value(@table.indices['index_users_on_reference']).must_equal(['reference'])
      end
    end
  end
end
