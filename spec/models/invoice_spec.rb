require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end

  before(:each) do
    @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_2 = Item.create!(name: "Soap", description: "This washes your skin", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 15, unit_price: 20, status: 2)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
      @ii_4 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_1.id, quantity: 25, unit_price: 10, status: 2)
      @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage: 10, threshold: 15)
      @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage: 25, threshold: 25)
  end
  
  describe "instance methods" do
    it "total_revenue" do
      expect(@invoice_1.total_revenue).to eq(460)
    end

    it "total_discounted_revenue" do
      expect(@invoice_1.total_discounted).to eq(4500)
    end

    it 'merchant_total_discount_revenue' do
      expect(@invoice_1.merchant_total_discount_revenue).to eq(415)
      expect(@invoice_2.merchant_total_discount_revenue).to eq(187.5)
    end
  end
end
