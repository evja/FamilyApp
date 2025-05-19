class FamilyMailer < ApplicationMailer
  def invitation_email(invitation)
    @invitation = invitation
    @family = invitation.family
    @url = accept_family_invitation_url(token: @invitation.token)

    mail(
      to: @invitation.email,
      subject: "You've been invited to join #{@family.name} on FamilyHub"
    )
  end
end 