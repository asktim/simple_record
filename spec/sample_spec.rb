require 'spec_helper'

describe 'Sample Usage' do
  let(:db) { ENV['simple_record_db'] || 'simple_record' }
  let(:connection) { PG.connect(dbname: db) }

  before { SimpleRecord.connection = connection }

  describe 'simple_record/schema' do
    class Article
      include Schema

      # Schema Definition
      attribute 'name', :string
      attribute 'description', :text
      attribute 'read_count', :integer
    end

    class CustomComment
      include Schema

      attribute 'text', :text
    end

    describe 'Class Methods' do
      it 'should produce table name' do
        expect(Article.table_name).to eql('article')
        expect(CustomComment.table_name).to eql('custom_comment')
      end

      it 'should create/drop db persistance' do
        sql = <<-SQL
          SELECT *
          FROM   information_schema.tables
          WHERE  table_catalog = '#{ db }'
          AND    table_name = '#{ Article.table_name }'
        SQL

        expect { Article.sql_create }.to change {
          connection.exec(sql).ntuples
        }.from(0).to(1)

        expect { Article.sql_drop }.to change {
          connection.exec(sql).ntuples
        }.from(1).to(0)
      end
    end

    context 'New Record' do
      let(:attributes) { {} }

      subject { Article.new(attributes) }

      it 'should respond to schema described methods' do
        is_expected.to respond_to(:name)
        is_expected.to respond_to(:description)
        is_expected.to respond_to(:read_count)
        is_expected.not_to respond_to(:text)
      end

      context 'with init attributes' do
        let(:attributes) { { 'name' => 'Mythbusters are gone', 'blah' => '' } }

        it 'should populate initialization values' do
          expect(subject.name).to eql('Mythbusters are gone')
          expect{ subject.blah }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
