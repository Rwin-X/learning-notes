#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Password Generator — Ruby + Tk GUI
# ------------------------------------
# A standalone desktop password generator using Ruby's built-in Tk bindings.
#
# Requirements:
#   - Ruby (2.5+ recommended)
#   - The 'tk' gem (on modern Ruby, Tk was split out of stdlib):
#       gem install tk
#     You also need Tcl/Tk installed on your OS:
#       Debian/Ubuntu: sudo apt install tcl-dev tk-dev
#       macOS (brew):  brew install tcl-tk
#       Windows:       the RubyInstaller "with Devkit" package bundles Tk
#
# Run:
#   ruby password_generator.rb

require 'tk'
require 'securerandom'

# ---------------------------------------------------------------------------
# Core password generation logic (kept separate from UI code)
# ---------------------------------------------------------------------------
module PasswordEngine
  LOWER   = ('a'..'z').to_a.freeze
  UPPER   = ('A'..'Z').to_a.freeze
  DIGITS  = ('0'..'9').to_a.freeze
  SYMBOLS = %w[! @ # $ % ^ & * ( ) - _ = + [ ] { } ; : , . < > ? /].freeze

  # Characters that look alike and are easy to misread/mistype.
  AMBIGUOUS = %w[l I 1 O 0 o].freeze

  class NoCharacterSetSelectedError < StandardError; end

  # Builds a password given a config hash:
  #   length:, use_lower:, use_upper:, use_digits:, use_symbols:, avoid_ambiguous:
  def self.generate(opts)
    pools = []
    pools << LOWER   if opts[:use_lower]
    pools << UPPER   if opts[:use_upper]
    pools << DIGITS  if opts[:use_digits]
    pools << SYMBOLS if opts[:use_symbols]

    raise NoCharacterSetSelectedError if pools.empty?

    if opts[:avoid_ambiguous]
      pools = pools.map { |pool| pool - AMBIGUOUS }
      pools = pools.reject(&:empty?)
      raise NoCharacterSetSelectedError if pools.empty?
    end

    full_set = pools.flatten

    # Guarantee at least one character from each selected pool, for passwords
    # long enough to fit them; this avoids generating e.g. an all-digit
    # password when "digits" was only one of several checked boxes.
    guaranteed = pools.map { |pool| pool.sample(random: SecureRandom) }
    remaining_length = [opts[:length] - guaranteed.size, 0].max

    body = Array.new(remaining_length) { full_set.sample(random: SecureRandom) }
    password = (guaranteed + body).shuffle(random: SecureRandom)

    # If length was shorter than the number of pools, trim down.
    password.first(opts[:length]).join
  end

  # Rough strength estimate based on pool size and length (log2 of keyspace).
  def self.estimate_entropy_bits(opts)
    pool_size = 0
    pool_size += LOWER.size   if opts[:use_lower]
    pool_size += UPPER.size   if opts[:use_upper]
    pool_size += DIGITS.size  if opts[:use_digits]
    pool_size += SYMBOLS.size if opts[:use_symbols]
    return 0 if pool_size.zero? || opts[:length].zero?

    (opts[:length] * Math.log2(pool_size)).round(1)
  end

  def self.strength_label(bits)
    case bits
    when 0...28       then ['Very Weak', '#e74c3c']
    when 28...36      then ['Weak', '#e67e22']
    when 36...60      then ['Reasonable', '#f1c40f']
    when 60...128     then ['Strong', '#2ecc71']
    else                   ['Very Strong', '#27ae60']
    end
  end
end

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------
class PasswordGeneratorApp
  def initialize
    @root = TkRoot.new { title 'Password Generator' }
    @root.resizable(0, 0) # fixed-size window; simplest to lay out reliably in Tk
    @root.geometry('480x430')

    # --- Tk variables bound to widgets ---
    @length_var    = TkVariable.new(16)
    @lower_var     = TkVariable.new(1)
    @upper_var     = TkVariable.new(1)
    @digits_var    = TkVariable.new(1)
    @symbols_var   = TkVariable.new(1)
    @ambiguous_var = TkVariable.new(0)
    @password_var  = TkVariable.new('')
    @strength_var  = TkVariable.new('')

    build_ui
    refresh_password
  end

  def run
    Tk.mainloop
  end

  private

  def build_ui
    pad = { padx: 12, pady: 6 }

    title_label = TkLabel.new(@root) do
      text 'Password Generator'
      font TkFont.new('Helvetica 16 bold')
    end
    title_label.pack(pad.merge(anchor: 'w'))

    build_output_row(pad)
    build_length_row(pad)
    build_checkbox_grid(pad)
    build_buttons_row(pad)
    build_strength_row(pad)
  end

  def build_output_row(pad)
    frame = TkFrame.new(@root)
    frame.pack(pad.merge(fill: 'x'))

    @output_entry = TkEntry.new(frame) do
      textvariable @password_var
      font TkFont.new('Courier 14')
      state 'readonly'
      width 28
    end
    @output_entry.pack(side: 'left', padx: [0, 8], fill: 'x', expand: true)

    copy_btn = TkButton.new(frame) do
      text 'Copy'
      command proc { copy_to_clipboard }
    end
    copy_btn.pack(side: 'left')
  end

  def build_length_row(pad)
    frame = TkFrame.new(@root)
    frame.pack(pad.merge(fill: 'x'))

    TkLabel.new(frame) { text 'Length:' }.pack(side: 'left')

    length_display = TkLabel.new(frame) { textvariable @length_var }
    length_display.pack(side: 'right')

    scale = TkScale.new(frame) do
      from_ 4
      to 64
      orient 'horizontal'
      variable @length_var
      showvalue false
      command proc { refresh_password }
    end
    scale.pack(side: 'left', fill: 'x', expand: true, padx: 8)
  end

  def build_checkbox_grid(pad)
    frame = TkLabelFrame.new(@root) { text 'Character Types' }
    frame.pack(pad.merge(fill: 'x'))

    options = [
      ['Lowercase (a-z)', @lower_var],
      ['Uppercase (A-Z)', @upper_var],
      ['Digits (0-9)', @digits_var],
      ['Symbols (!@#$...)', @symbols_var],
      ['Avoid ambiguous chars (l, I, 1, O, 0)', @ambiguous_var]
    ]

    options.each do |label_text, var|
      cb = TkCheckButton.new(frame) do
        text label_text
        variable var
        command proc { refresh_password }
      end
      cb.pack(anchor: 'w', padx: 10, pady: 2)
    end
  end

  def build_buttons_row(pad)
    frame = TkFrame.new(@root)
    frame.pack(pad.merge(fill: 'x'))

    generate_btn = TkButton.new(frame) do
      text 'Generate New Password'
      command proc { refresh_password }
    end
    generate_btn.pack(fill: 'x')
  end

  def build_strength_row(pad)
    @strength_label = TkLabel.new(@root) do
      textvariable @strength_var
      font TkFont.new('Helvetica 11 bold')
    end
    @strength_label.pack(pad.merge(anchor: 'w'))
  end

  def current_opts
    {
      length: @length_var.value.to_i,
      use_lower: @lower_var.value.to_i == 1,
      use_upper: @upper_var.value.to_i == 1,
      use_digits: @digits_var.value.to_i == 1,
      use_symbols: @symbols_var.value.to_i == 1,
      avoid_ambiguous: @ambiguous_var.value.to_i == 1
    }
  end

  def refresh_password
    opts = current_opts
    password = PasswordEngine.generate(opts)
    @password_var.value = password

    bits = PasswordEngine.estimate_entropy_bits(opts)
    label, color = PasswordEngine.strength_label(bits)
    @strength_var.value = "Strength: #{label}  (~#{bits} bits of entropy)"
    @strength_label.foreground = color
  rescue PasswordEngine::NoCharacterSetSelectedError
    @password_var.value = ''
    @strength_var.value = 'Select at least one character type.'
    @strength_label.foreground = '#e74c3c'
  end

  def copy_to_clipboard
    return if @password_var.value.empty?

    Tk.clipboard_clear
    Tk.clipboard_append(@password_var.value)
  end
end

PasswordGeneratorApp.new.run if __FILE__ == $PROGRAM_NAME
