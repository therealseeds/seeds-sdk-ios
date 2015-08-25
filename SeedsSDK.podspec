Pod::Spec.new do |s|
  s.name     = 'SeedsSDK'
  s.version  = '0.3.0'
  s.license  = {
    :type => 'COMMUNITY',
    :text => <<-LICENSE
              COUNTLY MOBILE ANALYTICS COMMUNITY EDITION LICENSE
              --------------------------------------------------

              Copyright (c) 2012, 2015 Countly

              Permission is hereby granted, free of charge, to any person obtaining a copy
              of this software and associated documentation files (the "Software"), to deal
              in the Software without restriction, including without limitation the rights
              to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
              copies of the Software, and to permit persons to whom the Software is
              furnished to do so, subject to the following conditions:

              The above copyright notice and this permission notice shall be included in
              all copies or substantial portions of the Software.

              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
              IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
              FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
              AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
              LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
              OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
              THE SOFTWARE.
    LICENSE
  }
  s.summary  = 'iOS SDK for the Seeds SDK'
  s.homepage = 'https://github.com/therealseeds/seeds-sdk-ios'
  s.author   = {'Seeds' => 'sungwon@playseeds.com'}
  s.source   = {
    :git => 'https://github.com/therealseeds/seeds-sdk-ios.git',
    :tag => s.version.to_s
  }
  s.source_files = 'SDK/**/*.{h,m}'
  s.public_header_files = 'SDK/Seeds.h'
  s.resources = 'SDK/**/*.{xcdatamodeld}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.ios.weak_framework = 'CoreTelephony', 'CoreData'
end
