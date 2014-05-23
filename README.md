[![Build Status](https://travis-ci.org/watu/table_builder.png?branch=master)](https://travis-ci.org/watu/table_builder)
[![Coverage Status](https://coveralls.io/repos/watu/table_builder/badge.png)](https://coveralls.io/r/watu/table_builder)
[![Code Climate](https://codeclimate.com/github/watu/table_builder.png)](https://codeclimate.com/github/watu/table_builder)
[![Gem Version](https://badge.fury.io/rb/watu_table_builder.png)](http://badge.fury.io/rb/watu_table_builder)

About watu_table_builder
========================

watu_table_builder is a fork of [table_builder](https://github.com/jchunky/table_builder) in an effort to bring it up to
speed with the current Ruby and Rails practices (bundler, gem, ci) as well as maybe re-vive it, start merging useful
branches, implementing new features, fixing bugs, etc.

Install
=======

Add this to your Gemfile:

    gem "watu_table_builder", :require => "table_builder"

or if you prefer to use it straight from GitHub:

    gem "watu_table_builder", :require => "table_builder", :git => "git://github.com/marclipovsky/table_builder.git"

TableBuilder
============

Rails builder for creating tables and calendars inspired by ActionView's FormBuilder, updated for Rails 3.0beta
This is a fork of Petrik de Heus plugin for earlier versions of Rails.  Note the new idiomatic use of "<%=" for the
table_for and calendar_for functions.

Examples
========

table_for has methods for each tag used in a table (table, thead, tr, td, etc.)

A basic example would look like this:

    @front_men = [FrontMan.new(1, 'David St. Hubbins'), FrontMan.new(2, 'David Lee Roth')]

and

    <%= table_for(@front_men) do |t| %>
      <%= t.head do %>
        <%= t.r do %>
          <%= t.h('Id') %>
          <%= t.h('Name') %>
        <% end %>
      <% end %>
      <%= t.body do |front_man| %>
        <%= t.r do %>
          <%= t.d(h(front_man.id)) %>
          <%= t.d(h(front_man.name)) %>
        <% end %>
      <% end %>
    <% end %>

You can pass an array to the head method:

    <%= t.head('Id', 'Name') %>

The body and r method can be combined for easier usage:

    <%= t.body_r do |front_man| %>
      <%= t.d(h(front_man.id)) %>
      <%= t.d(h(front_man.name)) %>
    <% end %>

You can also pass blocks to the d and h methods for more flexibility:


    <%= t.d(:class => 'name') do %>
      <%= link_to(h(front_man.name), front_man_url(front_man)) %>
    <% end %>

All tag methods are rails tag methods, so they can have extra html options.

    @drummers = [Drummer.new(1, 'John "Stumpy" Pepys'), Drummer.new(2, 'Eric "Stumpy Joe" Childs')]

and

    <%= table_for(@drummers, :html => { :id => 'spinal_tap', :class => 'drummers'}) do |t| %>
      <%= t.body_r(:class => 'row') do |e| %>
        <%= t.d(h(e.id), :title => 'id') %>
        <%= t.d(h(e.name)) %>
      <% end %>
    <% end %>

which produces the following html:

    <table class="drummers" id="spinal_tap">
      <tbody>
        <tr class="row">
          <td title="id">1</td>
          <td>John &quot;Stumpy&quot; Pepys</td>
        </tr>
        <tr class="row">
          <td title="id">2</td>
          <td>Eric &quot;Stumpy Joe&quot; Childs</td>
        </tr>
      </tbody>
    </table>


You can customize the table by creating your own TableBuilder:

    <%= table_for(@drummers, :builder => PagedTableBuilder) do |t| %>

Calendar Table
==============

calendar_for creates a table like table_for.
All objects get sorted per day of the month

A basic example would look like this:

    @tasks = Task.this_month

and

    <%= calendar_for(@tasks) do |t| %>
      <%= t.head('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun') %>
      <%= t.day do |day, tasks| %>
        <%= day.day %>
        <% tasks.each do |task| %>
          <%= h(task.name) %>
        <% end %>
      <% end %>
    <% end %>

To show a different month you can pass the :year and :month options:

    <%= calendar_for(@tasks, :year => 2009, :month => 1) do |t| %>

To highlight a different day you can pass the :today option:

    <%= calendar_for(@tasks, :today => Date.civil(2008, 12, 26)) do |t| %>

By default the :date method is called on the objects for sorting.
To use another method you can pass the :day_method option:

    <%= t.day(:day_method => :calendar_date) do |day, tasks| %>

Or you can pass an array of methods to the :day_method option:

    <%= t.day(:day_method => [:start_date, :end_date]) do |day, tasks| %>

If you want to add id's to your td tag you can pass a pattern:

    <%= t.day(:id => 'day_%d') do |day, tasks| %>

To have a header at the begining of each row:

    <%= calendar_for(@tasks, :row_header => true) do |t| %>

and then in your block you get nil as the list of objects and the first day of thet upcoming week. For example:

    <%= calendar_for(@tasks) do |t| %>
      <%= t.day do |day, tasks| %>
        <% if tasks.nil? %>
          <%= day.cweek %>
        <% else %>
          <%= day.day %>
          <% tasks.each do |task| %>
            <%= h(task.name) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>

Contributing
============

Document any new options and verify the documentation looks correct by running:

    yard server --reload

and going to http://localhost:8808

Contributors
============

Petrik de Heus, Sean Dague, F. Kocherga, John Duff, Andrew C. Greenberg, Jason Cheong-Kee-You, [J. Pablo Fernández](http://pupeno.com).

Original Work Copyright (c) 2008 Petrik de Heus, released under the MIT license.

Fork revisions Copyright (c) 2010 Andrew C. Greenberg, released under the MIT license.

Fork revisions Copyright (c) 2012 [Carrousel Apps Ltd (Watu)](http://watuhq.com), released under the MIT license.
