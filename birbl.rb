require 'birbl'
require 'yaml'

Birbl::Client.new('development')
Birbl::Client.instance.dev_url = 'http://localhost:8080'
Birbl::Client.instance.use_sandbox = true

#puts Birbl::Activity.active.to_yaml
exit

#Birbl::Reservation.payment_due.each { |d| puts d.inspect }
#user = Birbl::User.create(:email => 'aaron@birbl.com', :username => 'aaroncraig')
#puts user.to_yaml
#exit

#user = Birbl::User.find_by_email('aaron@birbl.com')
#puts user.to_yaml
#exit

#partner = Birbl::Partner.find_by_email('colm@yogadublin.com')
#reservation = partner.activities[0].reserve('2013-02-26T09:00:00+00:00')
#puts reservation.to_yaml
#exit

#activity = Birbl::Activity.find(1)
#puts activity.digital_asset_urls.class.to_s

#reservation = Birbl::Reservation.find(1)
#puts reservation.to_yaml
#exit
#reservation.state = 'opt_in'
#reservation.save
#exit

#partner= Birbl::Partner.find(456)
#partner.website = 'www.google.com'
#partner.description = 'This is &#39; some text.'
#partner.save
#exit

#partners = Birbl::Partner.all
#puts partners.to_yaml
#exit


partner_data = {
  'id'      => 1,
  'name'    => 'Dummy partner',
  'email'   => 'partner@example.com',
  'website' => 'www.example.com'
}

partner = Birbl::Partner.find(456)

activity_data = {
  'name'                  => 'Dummy activity',
  'description'           => 'Activity desription',
  'base_price'            => 1000,
  'minimum_price'         => 100,
  'maximum_capacity'      => 10,
  'minimum_participants'  => 1,

  # optional
  'variation_limit'       => 4,
  'cost_per_participant'  => 100,
  'fixed_costs'           => 300
}

activity = partner.activity(1225)
Birbl::Activity.delete(1225, partner)
