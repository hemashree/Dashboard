class Video < ActiveRecord::Base


	 # validates :link, presence: true, format: YT_LINK_FORMAT

	before_create :validate_link

	def YT_LINK_FORMAT 
	  /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i
	end

	def validate_link
		binding.pry
		uid = link.match self.YT_LINK_FORMAT
		self.uid = uid[2] if uid && uid[2]

		if self.uid.to_s.length != 11
			binding.pry
			self.errors.add(:link, 'is invalid.')
			false
		elsif Video.where(uid: self.uid).any?
			self.errors.add(:link, 'is not unique.')
			false
		else
			get_additional_info
		end
	end

	 private
 
	def get_additional_info
	  begin
	    client = YouTubeIt::OAuth2Client.new(dev_key: 'AIzaSyAZS_k66pahEd0j8YH8g3wfsh_KeI-NoFc')
	    video = client.video_by(uid)
	    self.title = video.title
	    self.duration = parse_duration(video.duration)
	    self.author = video.author.name
	    self.likes = video.rating.likes
	    self.dislikes = video.rating.dislikes
	  rescue
	    self.title = '' ; self.duration = '00:00:00' ; self.author = '' ; self.likes = 0 ; self.dislikes = 0
	  end
	end

	def parse_duration(d)
	  hr = (d / 3600).floor
	  min = ((d - (hr * 3600)) / 60).floor
	  sec = (d - (hr * 3600) - (min * 60)).floor
	 
	  hr = '0' + hr.to_s if hr.to_i < 10
	  min = '0' + min.to_s if min.to_i < 10
	  sec = '0' + sec.to_s if sec.to_i < 10
	  hr.to_s + ':' + min.to_s + ':' + sec.to_s
	end
end

	# client = YouTubeIt::OAuth2Client.new( client_id: "1002641400828-osj692bu7vbstt4ef4njv756r0nn472j.apps.googleusercontent.com", client_secret: "0VEYAvIbdrBOaqbyHzXHEk3Y", dev_key: "AIzaSyAZS_k66pahEd0j8YH8g3wfsh_KeI-NoFc")