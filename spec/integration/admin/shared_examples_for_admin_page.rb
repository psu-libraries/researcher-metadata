shared_examples_for "a page with the admin layout" do
  it "shows a link to the duplicate publication groups index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Duplicate publication groups'
    end
  end

  it "shows a link to the EDTs index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'ETDs'
    end
  end

  it "shows a link to the Organizations index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Organizations'
    end
  end

  it "shows a link to the presentations index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Presentations'
    end
  end

  it "shows a link to the publications index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Publications'
    end
  end

  it "shows a link to the performances index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Performances'
    end
  end

  it "shows a link to the users index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Users'
    end
  end

  it "shows a link to the grants index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Grants'
    end
  end

  it "shows a link to the internal publication waivers index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Internal publication waivers'
    end
  end

  it "shows a link to the external publication waivers index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'External publication waivers'
    end
  end

  it "shows a link to the authorships index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Authorships'
    end
  end

  it "shows a link to the email errors index" do
    within '.sidebar-nav' do
      expect(page).to have_link 'Email errors'
    end
  end

  it "shows a link to the admin dashboard" do
    expect(page).to have_link 'Dashboard'
  end

  it "shows a link to the public home page" do
    expect(page).to have_link 'Home', href: root_path
  end

  it "shows a logout link" do
    expect(page).to have_link 'Log out', href: destroy_user_session_path
  end
end
