require 'selenium-webdriver'

class SauceLabs
  def initialize(user, key)
    @user = user
    @key = key
  end
  
  def get_url
    "http://#{@user}:#{@key}@ondemand.saucelabs.com:80/wd/hub"
  end
  
  def snapshot(url)
    driver = Selenium::WebDriver.for(:remote,
      :url => get_url,
      :desired_capabilities => {
          browserName: "Firefox",
          name: "snap-it-up"
        })
    driver.navigate.to url
    image = driver.screenshot_as(:png)
    driver.quit
    image
  end
end
