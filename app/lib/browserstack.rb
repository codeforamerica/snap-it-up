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
      desired_capabilities: {
          browser: "Firefox",
          project: "snap-it-up-rails"
        }

    driver.navigate.to url

    # Returns a File
    image = driver.screenshot_as :png

    # If we don't explicitly quit, Browserstack is left hanging!
    driver.quit
    image
  end
end
