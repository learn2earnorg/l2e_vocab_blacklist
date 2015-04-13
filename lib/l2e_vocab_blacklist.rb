require 'active_support/inflector'

class VocabBlacklist

	# Returns true or false, check to see if the 
	def self.blacklisted?(str)
		# Sanitize string
		str = str.downcase.strip.gsub(CONSIDER_REGEX, '')

		# Blacklist if any of the words 
		str.split(" ").each do |word|
			return true if FULL_WORDS.include?(word)
		end

		# For compound dirty words
		PHRASES.each do |bad_phrase|
			return true if str.include?(bad_phrase)
		end
		
		return GREEDY_WORDS.any? { |s| str.include?(s) }
	end

	def self.censor(str, replace_with = "****")

		PHRASES.each do |bad_phrase|
			str.gsub!(/#{bad_phrase}/i, replace_with)
		end

		str.split(" ").map do |working_word|
			word = working_word.downcase.strip.gsub(CONSIDER_REGEX, '')

			if FULL_WORDS.include?(word)
				working_word.gsub!(/#{word}/i, replace_with)
			end

			if GREEDY_WORDS.any? { |w| word.include?(w) }
				working_word = replace_with
			end

			working_word
		end.join(" ")
	end

	def self.file_to_nomalized_words(file)
		File.read(file).split("\n").reject { |s| s.to_s.strip.empty? }.map(&:downcase).map { |s| s.gsub(CONSIDER_REGEX, '') }
	end

	def self.words_with_expansions(words)
		words.map { |s| [s, s.pluralize, s.singularize] }.uniq.flatten
	end

	BLACKLIST_DIR = File.join(File.dirname(__FILE__), 'l2e_vocab_blacklist/blacklists')
	CONSIDER_REGEX = /[^0-9a-z\* ]/i

	PHRASES = file_to_nomalized_words("#{BLACKLIST_DIR}/full_words.txt").select { |w| w.split(" ").length > 1 }
	FULL_WORDS = file_to_nomalized_words("#{BLACKLIST_DIR}/full_words.txt").reject { |w| w.split(" ").length > 1 }
	GREEDY_WORDS = words_with_expansions(file_to_nomalized_words("#{BLACKLIST_DIR}/greedy_words.txt")).uniq.freeze

end