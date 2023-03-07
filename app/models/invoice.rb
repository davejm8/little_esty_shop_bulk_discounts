class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :items

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_discounted
    rev = invoice_items.joins(item: { merchant: :bulk_discounts }).where('invoice_items.quantity >= bulk_discounts.threshold').group('invoice_items.id').select('MAX(invoice_items.unit_price * invoice_items.quantity * bulk_discounts.percentage) as total')
    rev.sum(&:total)
  
  end

  def merchant_total_discount_revenue
    converted = total_discounted / 100
    total_revenue - converted
  end

  # def discounted_items(merchant_id)
  #   invoice_items.joins(:bulk_discounts)
  #   .where(merchants: {id: merchant_id})
  #   .where("invoice_items.quantity >= bulk_discounts.threshold")
  #   .group(:id)
  #   .select("max(bulk_discounts.percentage) as max_discount, invoice_items.*")
  #   #select the highest percentage discount that the quantity applies to
  # end
end
