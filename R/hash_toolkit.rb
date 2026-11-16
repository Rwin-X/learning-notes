#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Hash Identifier + Dictionary Cracker
# --------------------------------------
# Identifies likely hash algorithm(s) from a hash string's length/charset,
# and attempts dictionary-based cracking (optionally with common mutations).
#
# Supports: MD5, SHA-1, SHA-256, SHA-384, SHA-512 (Ruby stdlib 'digest' only).
# Note: Ruby's stdlib does not include SHA-224; if you need it, the
# 'openssl' library (also stdlib) can provide it via OpenSSL::Digest::SHA224.
#
# LEGAL / ETHICAL NOTE:
# Only use this against hashes you have permission to test (your own
# accounts, a CTF challenge, an authorized pentest). Cracking credentials
# you don't own is illegal in most jurisdictions.
#
# Usage:
#   ruby hash_toolkit.rb identify <hash_string>
#   ruby hash_toolkit.rb crack <hash_string> <wordlist_file> [--mutate]
#
# Examples:
#   ruby hash_toolkit.rb identify 5f4dcc3b5aa765d61d8327deb882cf99
#   ruby hash_toolkit.rb crack 5f4dcc3b5aa765d61d8327deb882cf99 rockyou.txt --mutate

require 'digest'

ALGORITHMS = {
  'MD5'     => { length: 32,  digest: Digest::MD5 },
  'SHA-1'   => { length: 40,  digest: Digest::SHA1 },
  'SHA-256' => { length: 64,  digest: Digest::SHA256 },
  'SHA-384' => { length: 96,  digest: Digest::SHA384 },
  'SHA-512' => { length: 128, digest: Digest::SHA512 }
}.freeze

HEX_RE = /\A[0-9a-fA-F]+\z/.freeze

IdentificationResult = Struct.new(:candidates, :length, :hex)

def identify_hash(hash_string)
  cleaned = hash_string.strip
  is_hex = HEX_RE.match?(cleaned)
  length = cleaned.length

  candidates = []
  if is_hex
    ALGORITHMS.each do |name, info|
      candidates << name if length == info[:length]
    end
  end

  IdentificationResult.new(candidates, length, is_hex)
end

def hash_with(algorithm_name, text)
  ALGORITHMS.fetch(algorithm_name)[:digest].hexdigest(text)
end

# Yields common, cheap mutations of a dictionary word: case variants plus
# common numeric/symbol suffixes. This is intentionally a small, fast set
# (not a full rule engine like Hashcat's best64) -- good enough for weak or
# reused passwords, not a replacement for a real rule-based cracker.
def generate_mutations(word)
  word = word.strip
  return [] if word.empty?

  bases = [word, word.downcase, word.upcase, word.capitalize].uniq
  suffixes = ['', '1', '12', '123', '!', '2024', '2025', '2026']

  bases.flat_map { |base| suffixes.map { |suffix| base + suffix } }
end

# Returns [algorithm, plaintext] on success, or nil if exhausted.
def crack_hash(target_hash, wordlist_path, algorithms, use_mutations)
  target_hash = target_hash.strip.downcase

  unless File.exist?(wordlist_path)
    warn "Error: wordlist file not found: #{wordlist_path}"
    exit(1)
  end

  File.foreach(wordlist_path, encoding: 'UTF-8', invalid: :replace, undef: :replace) do |line|
    word = line.chomp
    next if word.empty?

    candidates = use_mutations ? generate_mutations(word) : [word]
    candidates.each do |candidate|
      algorithms.each do |algo|
        return [algo, candidate] if hash_with(algo, candidate) == target_hash
      end
    end
  end

  nil
end

def cmd_identify(hash_string)
  result = identify_hash(hash_string)

  puts "Input length: #{result.length} characters"
  puts "Hexadecimal:  #{result.hex ? 'yes' : 'no'}"

  unless result.hex
    puts "\nThis does not look like a hex-encoded hash (it contains"
    puts 'non-hex characters). It may be base64-encoded, salted with a'
    puts 'delimiter (e.g. hash:salt), or not a hash at all.'
    return
  end

  if result.candidates.empty?
    puts "\nNo standard MD5/SHA-1/SHA-2 algorithm matches this length."
    puts 'It may be a different algorithm (e.g. bcrypt, scrypt, NTLM),'
    puts 'a truncated hash, or include a salt.'
    return
  end

  puts "\nPossible algorithm(s) based on length (#{result.length} hex chars):"
  result.candidates.each { |name| puts "  - #{name}" }

  return unless result.candidates.size > 1

  puts "\nNote: multiple algorithms share this digest length " \
       '(e.g. MD5/MD4/NTLM are all 32 hex chars). Length alone cannot' \
       ' distinguish them -- context (where the hash came from) usually can.'
end

def cmd_crack(hash_string, wordlist, mutate)
  result = identify_hash(hash_string)

  algorithms =
    if result.hex && !result.candidates.empty?
      puts "Identified candidate algorithm(s): #{result.candidates.join(', ')}"
      result.candidates
    else
      puts 'Could not confidently identify the algorithm from hash length.'
      puts 'Falling back to trying all supported algorithms.'
      ALGORITHMS.keys
    end

  puts "Loading wordlist: #{wordlist}"
  puts "Mutations: #{mutate ? 'enabled' : 'disabled'}"
  puts "Starting crack attempt... (Ctrl+C to abort)\n\n"

  start = Time.now
  found = begin
    crack_hash(hash_string, wordlist, algorithms, mutate)
  rescue Interrupt
    puts "\nAborted by user."
    exit(130)
  end
  elapsed = Time.now - start

  if found
    algo, plaintext = found
    puts "\n[CRACKED] Algorithm: #{algo}"
    puts "[CRACKED] Plaintext: #{plaintext}"
    puts "Time elapsed: #{elapsed.round(2)}s"
  else
    puts "\nNo match found in wordlist (elapsed: #{elapsed.round(2)}s)."
    puts "Try --mutate if you haven't, or a larger/targeted wordlist."
  end
end

def print_usage
  puts <<~USAGE
    Usage:
      ruby hash_toolkit.rb identify <hash_string>
      ruby hash_toolkit.rb crack <hash_string> <wordlist_file> [--mutate]
  USAGE
end

def main
  command = ARGV[0]

  case command
  when 'identify'
    if ARGV[1].nil?
      print_usage
      exit(1)
    end
    cmd_identify(ARGV[1])
  when 'crack'
    if ARGV[1].nil? || ARGV[2].nil?
      print_usage
      exit(1)
    end
    mutate = ARGV.include?('--mutate')
    cmd_crack(ARGV[1], ARGV[2], mutate)
  else
    print_usage
    exit(1)
  end
end

main if __FILE__ == $PROGRAM_NAME
