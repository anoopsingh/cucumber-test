require "capybara/cucumber"
require "selenium/webdriver"
require 'sauce_whisk'


puts (ENV['version'])
Around do |scenario, block|
  block.call
  sessionid = ::Capybara.current_session.driver.browser.session_id
  ::Capybara.current_session.driver.quit

  # sessionid = Capybara.current_session.driver.browser.session_id
  jobname = "#{scenario.feature.name} - #{scenario.name}"

  # Output sessionId and jobname to std out for Sauce OnDemand Plugin to display embeded results
  puts "SauceOnDemandSessionID=#{sessionid} job-name=#{jobname}"

  job = SauceWhisk::Jobs.fetch sessionid
  job.name = jobname
  job.passed = scenario.passed? ? true : false
  job.save
end

Before do | scenario |
  Capybara.register_driver :selenium do |app|
    capabilities = {
      :version => ENV['version'],
      :browserName => ENV['browserName'],
      :platform => ENV['platform']
    }
    puts('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh')
    url = "http://#{'letsautomate'}:#{'6557fe67-abf1-42f7-b245-f881d68510f8'}@ondemand.saucelabs.com:80/wd/hub".strip
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote, :url => url,
                                   :desired_capabilities => capabilities)
  end
  Capybara.default_wait_time = 10
  Capybara.current_driver = :selenium

  job = SauceWhisk::Jobs.fetch ::Capybara.current_session.driver.browser.session_id
  job.name = "#{scenario.feature.name} - #{scenario.name}"
  job.save
end
