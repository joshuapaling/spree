class UpgradeAdjustments < ActiveRecord::Migration
  def up
    # Shipping adjustments are now tracked as fields on the object
    Spree::Adjustment.where(:source_type => "Spree::Shipment").find_each do |adjustment|
      adjustment.source.update_column(:cost, adjustment.amount)
      adjustment.destroy
    end

    # Tax adjustments have their sources altered
    Spree::Adjustment.where(:originator_type => "Spree::TaxRate").find_each do |adjustment|
      adjustment.source = adjustment.originator
      adjustment.save
    end

    # Promotion adjustments have their source altered also
    Spree::Adjustment.where(:originator_type => "Spree::PromotionAction").find_each do |adjustment|
      adjustment.source = adjustment.originator
      if adjustment.source.calculator_type == "Spree::Calculator::FreeShipping"
        # Previously this was a Spree::Promotion::Actions::CreateAdjustment
        # And it had a calculator to work out FreeShipping
        # In Spree 2.2, the "calculator" is now the action itself.
        adjustment.source.becomes(Spree::Promotion::Actions::FreeShipping)
      end

      adjustment.save
    end
  end
end
