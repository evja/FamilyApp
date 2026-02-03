class BillingController < ApplicationController
  before_action :authenticate_user!

  def checkout
    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price: Rails.application.credentials.dig(:stripe, :price_id) || ENV.fetch('STRIPE_PRICE_ID'),
        quantity: 1
      }],
      mode: "subscription", # or "payment" for one-time
      success_url: root_url + "?checkout=success",
      cancel_url: root_url + "?checkout=cancel"
    )

    redirect_to session.url, allow_other_host: true
  end
end