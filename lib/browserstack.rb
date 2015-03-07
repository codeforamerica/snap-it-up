require 'selenium-webdriver'

class Browserstack
  def initialize(user, key)
    @user = user
    @key = key
  end
  
  def get_url
    "http://#{BROWSERSTACK_USER}:#{BROWSERSTACK_KEY}@hub.browserstack.com/wd/hub"
  end
  
  def snapshot(url)
    driver = Selenium::WebDriver.for(:remote,
      :url => get_url,
      :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.firefox)
    driver.navigate.to url
    driver.screenshot_as(:png)
  end
end
