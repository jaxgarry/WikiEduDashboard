# frozen_string_literal: true
require 'rails_helper'

describe 'the explore page', type: :feature, js: true do
  describe 'control bar' do
    it 'should allow sorting via dropdown' do
      visit '/explore'

      # sorting via dropdown
      find('#courses select.sorts').find(:xpath, 'option[2]').select_option
      expect(page).to have_selector('[data-sort="revisions"].sort.desc')
      find('#courses select.sorts').find(:xpath, 'option[3]').select_option
      expect(page).to have_selector('[data-sort="characters"].sort.desc')
      find('#courses select.sorts').find(:xpath, 'option[5]').select_option
      expect(page).to have_selector('[data-sort="views"].sort.desc')
      find('#courses select.sorts').find(:xpath, 'option[6]').select_option
      expect(page).to have_selector('[data-sort="students"].sort.desc')
      find('#courses select.sorts').find(:xpath, 'option[1]').select_option
      expect(page).to have_selector('[data-sort="title"].sort.asc')
    end
  end

  describe 'course list' do
    it 'should be sortable' do
      visit '/explore'

      # Sortable by title
      expect(page).to have_selector('#courses [data-sort="title"].sort.asc')
      find('#courses [data-sort="title"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="title"].sort.desc')

      # Sortable by character count
      find('#courses [data-sort="characters"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="characters"].sort.desc')
      find('#courses [data-sort="characters"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="characters"].sort.asc')

      # Sortable by view count
      find('#courses [data-sort="views"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="views"].sort.desc')
      find('#courses [data-sort="views"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="views"].sort.asc')

      # Sortable by student count
      find('#courses [data-sort="students"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="students"].sort.desc')
      find('#courses [data-sort="students"].sort').trigger('click')
      expect(page).to have_selector('#courses [data-sort="students"].sort.asc')
    end
  end

  describe 'rows' do
    before do
      campaign = Campaign.default_campaign
      course = create(:course,
        id: 1,
        start: '2014-01-01'.to_date,
        end: Time.zone.today + 2.days)
      CampaignsCourses.create(
        campaign_id: campaign.id,
        course_id: 1)
      user = create(:user, id: 1, trained: true)
      create(:courses_user,
             id: 1,
             course_id: 1,
             user_id: 1,
             role: CoursesUsers::Roles::STUDENT_ROLE)
    end

    it 'should allow navigation to a campaign page' do
      visit '/explore'
      find('#campaigns .table tbody tr:first-child').click
      expect(current_path).to eq("/campaigns/#{Campaign.first.slug}/overview")
    end

    it 'should allow navigation to a course page' do
      visit '/explore'
      find('#courses .table tbody tr:first-child').click
      expect(current_path).to eq("/courses/#{course.slug}")
    end

    it 'should show the stats accurately' do
      article = create(:article,
                       id: 1,
                       title: 'Selfie',
                       namespace: 0)
      create(:articles_course,
             course_id: 1,
             article_id: 1)
      create(:revision,
             id: 1,
             user_id: 1,
             article_id: 1,
             date: 6.days.ago,
             characters: 9000)
      visit '/explore'

      # Number of courses
      expect(page.find('#campaigns .table tbody tr:first-child .num-courses-human').text).to eq('1')

      # Recent revisions
      expect(page.find('#courses .table tbody tr:first-child .revisions').text).to eq('1')
    end
  end
end
