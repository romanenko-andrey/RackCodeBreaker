Capybara.default_driver = :poltergeist
Capybara.app_host = "http://localhost:9292"


RSpec.describe Racker do

  context 'after correct answer input' do
    before do
      allow_any_instance_of(RavCodebreaker::Game).to receive(:win?).and_return(true)
      allow_any_instance_of(Object).to receive(:win?).and_return(true)
      visit '/'
      fill_in 'name', :with => 'Andrii'
      find('label.button', text:'expert').click
      click_button 'Start'
    end

    it "have to displays congradulation message" do
      fill_in 'guess', :with => '1111'
      click_on 'SEND'
      expect( find('#container').text ).to match(/Congradulations. You've win!!!/)
    end
  end

  context 'unknown path' do
    it "return PageNotFound status code (404)" do
      visit '/non_exist_page'
      expect(status_code).to be(404)
    end
  end

  context "visit root" do
    before { visit '/' }

    it "displays CODEBREAKER GAME on start page" do
      expect(page).to have_content 'CODEBREAKER GAME'
    end

    it "displays empty player name" do
      expect(page).to have_css("input.text_input", text: '')
    end

    it "displays 3 buttons for level select" do
      expect(page).to have_selector(:xpath, "//form//div[count(input)=3]")
    end

    it "displays Beginner as start level" do
       expect(page).to have_css('label.button', text:'beginner')
       expect(find('#level1').value).to eq('beginner')
       expect(find('#level1')['checked']).to be_truthy
    end

    context 'ShowHelp link' do
      it "start page must have link to show help" do
        expect(find('a#help_link')[:text]).to match(/Show help/)
      end
      it "start page must be without help description" do
        expect(page).not_to have_css('div.help')
      end
      it 'help description appears after the link click' do
        click_link 'help_link'
        expect(page).to have_css('div.help')
      end
    end
  end

  describe 'game page with Master level' do
    before(:all) do
      visit '/'
      fill_in 'name', :with => 'Andrii'
      find('label.button', text:'master').click
      click_button 'Start'
    end

    context 'start after enter name, level select and press Start button' do
      it 'the new page must be find with status (200)' do
        expect(status_code).to be(200)
      end
      it 'new page have to start with correct user name' do
        expect(page).to have_content('Hello, Andrii!')
      end
      it 'new page have to start on selected level' do
        expect(page).to have_content('You have 15 attempts and 1 hints.')
      end
      it 'return incorrect message when enter empty code' do
        click_on 'SEND'
        expect(page).to have_content('Incorrect number format, try again, please')
      end
      it 'redirect to update_game page after click on SEND button' do
        click_on 'SEND'
        expect(current_url).to match(/update_game\?id=/)
      end
      it 'return game_over message after 15 incorrect answers' do
        15.times do
          fill_in 'guess', :with => '1111'
          click_on 'SEND'
        end
        expect(page).to have_content('Sorry, you lose the game')
      end
    end
  end

  describe 'game with Master level' do
    before(:all)  do
      visit '/'
      fill_in 'name', :with => 'Andrii'
      find('label.button', text:'expert').click
      click_button 'Start'
    end

    context 'start with correct initial values' do
      it 'when correct user name' do
        expect(page).to have_content('Hello, Andrii!')
      end
      it 'new page have to start on selected level' do
        expect(page).to have_content('You have 10 attempts and 0 hints.')
      end
    end
  end
end



