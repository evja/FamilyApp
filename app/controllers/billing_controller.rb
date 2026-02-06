class BillingController < ApplicationController
  before_action :authenticate_user!

  def checkout
    unless current_user.family
      redirect_to root_path, alert: "Please create a family first."
      return
    end

    stripe_session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price: Rails.application.credentials.dig(:stripe, :price_id) || ENV.fetch('STRIPE_PRICE_ID'),
        quantity: 1
      }],
      mode: "subscription",
      success_url: root_url + "?checkout=success",
      cancel_url: root_url + "?checkout=cancel"
    )

    redirect_to stripe_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to root_path, alert: "Payment error: #{e.message}"
  end
end