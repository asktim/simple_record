require 'spec_helper'

# Sample classes with schema features switched on
class CustomComment
  include Schema

  attribute 'text', :text
end

class Article
  include Schema

  # Schema Definition
  attribute 'name', :string
  attribute 'description', :text
  attribute 'read_count', :integer
end

describe 'Sample Usage' do
  before(:context) do
    SimpleRecord.connection = PG.connect(dbname: ENV['simple_record_db'] || 'simple_record')
  end

  let(:db) { connection.conninfo_hash[:dbname] }
  let(:connection) { SimpleRecord.connection }

  before(:all) do
    Article.dt_create
  end

  after(:all) { Article.dt_drop }

  describe 'simple_record/schema' do
    describe 'Class Methods' do
      it '#table_name' do
        expect(Article.table_name).to eql('article')
        expect(CustomComment.table_name).to eql('custom_comment')
      end

      it '#create/#drop' do
        sql = <<-SQL
          SELECT *
          FROM   information_schema.tables
          WHERE  table_catalog = '#{ db }'
          AND    table_name = '#{ CustomComment.table_name }'
        SQL

        expect { CustomComment.dt_create }.to change {
          connection.exec(sql).ntuples
        }.from(0).to(1)

        expect { CustomComment.dt_drop }.to change {
          connection.exec(sql).ntuples
        }.from(1).to(0)
      end
    end

    context 'New Record' do
      let(:attributes) { {} }

      subject { Article.new(attributes) }

      it 'should respond to attributes methods' do
        is_expected.to respond_to(:name)
        is_expected.to respond_to(:description)
        is_expected.to respond_to(:read_count)
        is_expected.not_to respond_to(:text)
      end

      context 'builded with init attributes' do
        let(:attributes) do
          {
            'name' => 'Mythbusters are gone',
            'blah' => '',
            'description' => 'Description describes'
          }
        end

        it 'should populate attributes values' do
          expect(subject.name).to eql('Mythbusters are gone')
          expect(subject.description).to eql('Description describes')
          expect{ subject.blah }.to raise_error(NoMethodError)
        end

        it 'can be saved' do
          expect{ subject.create }.to change {
            connection.exec(<<-SQL).ntuples
              SELECT * FROM #{ Article.table_name }
            SQL
          }.by(1)
        end
      end
    end

    describe 'Finding Scopes' do
      before(:all) do
        Article.new('name' => 'Name1', 'read_count' => 1).create
        Article.new('name' => 'Name2', 'read_count' => 2).create
        Article.new('name' => 'Name3', 'read_count' => 3).create
      end

      it 'can be joined' do
        scope = Article.where('read_count > ?', [1]).where('name = ?', ['Name3'])
        finded = scope.first
        expect(finded).to be_a Article
      end
    end
  end
end
