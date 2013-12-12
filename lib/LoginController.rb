# encoding: utf-8

require 'mechanize'

# Downloads videos according to options specified
class LoginController
  INTERNAL_URL = 'https://myvideosu.stanford.edu/oce/currentquarter.aspx'
  TWO_STEP_AUTH_REGEX = /Two-step authentication/

  public

  def login(agent)
    # Load cookies if available
    agent.cookie_jar.load 'cookies', session: true, format: :yaml if
      File.exist?('cookies')

    page = agent.get(INTERNAL_URL)

    # Fill out the login form
    while page.form('login') && !(page.content =~ TWO_STEP_AUTH_REGEX)
      page = fill_login_page agent, page
    end

    (fill_two_step_auth_page agent, page) if
      page.content =~ TWO_STEP_AUTH_REGEX

    # Save cookies
    agent.cookie_jar.save_as 'cookies', session: true, format: :yaml
  end

  private

  def fill_login_page(agent, page)
    login_form = page.form('login')
    print 'SUNet ID: '
    login_form.username = gets.strip
    print 'SUNet Password: '
    login_form.password = STDIN.noecho(&:gets).strip
    login_form.checkboxes.first.checked = true
    puts "\nLogging in..."

    agent.submit(login_form, login_form.buttons.first)
  end

  def fill_two_step_auth_page(agent, page)
    print 'Two-step authentication code: '
    login_form = page.form('login')
    login_form.otp = gets.strip
    agent.submit(login_form, login_form.buttons.first)
  end

end
