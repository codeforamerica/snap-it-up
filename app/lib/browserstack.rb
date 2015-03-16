require 'selenium-webdriver'

class Browserstack
  def self.screenshot(url)
    new.screenshot url
  end

  def initialize(user: ENV['BROWSERSTACK_USER'], key: ENV['BROWSERSTACK_KEY'])
    @user = user
    @key = key
  end

  def screenshot(url)
    driver = Selenium::WebDriver.for :remote,
      url: "http://#{@user}:#{@key}@hub.browserstack.com/wd/hub",
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox

    driver.navigate.to url

    # Returns a File
    driver.screenshot_as :png
  end
end
