# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180119154458) do

  create_table "answers", force: :cascade do |t|
    t.string "title"
    t.integer "vote", default: 0
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.integer "size_type"
    t.integer "effectif", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_invits", force: :cascade do |t|
    t.string "email"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_invits_on_company_id"
  end

  create_table "company_users", force: :cascade do |t|
    t.integer "admin", default: 0
    t.boolean "invitation", default: false
    t.boolean "participation", default: false
    t.string "email"
    t.integer "user_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_users_on_company_id"
    t.index ["user_id"], name: "index_company_users_on_user_id"
  end

  create_table "elements", force: :cascade do |t|
    t.integer "cat"
    t.integer "group_id"
    t.integer "post_id"
    t.integer "user_id"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "task_id"
    t.index ["group_id"], name: "index_elements_on_group_id"
    t.index ["post_id"], name: "index_elements_on_post_id"
    t.index ["question_id"], name: "index_elements_on_question_id"
    t.index ["task_id"], name: "index_elements_on_task_id"
    t.index ["user_id"], name: "index_elements_on_user_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "favorit", default: false
    t.boolean "request", default: false
    t.boolean "invitation", default: false
    t.boolean "participation", default: false
    t.boolean "admin", default: false
    t.integer "invitor_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "cat", default: 3
    t.integer "effectif", default: 1
    t.integer "pend_req", default: 0
    t.integer "user_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_groups_on_company_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_posts_on_group_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title"
    t.integer "voters", default: 0
    t.boolean "multiple", default: false
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_questions_on_group_id"
  end

  create_table "sub_tasks", force: :cascade do |t|
    t.string "title"
    t.boolean "done", default: false
    t.datetime "done_at"
    t.integer "doner_id"
    t.integer "task_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_sub_tasks_on_task_id"
    t.index ["user_id"], name: "index_sub_tasks_on_user_id"
  end

  create_table "task_reminds", force: :cascade do |t|
    t.boolean "deleted_state", default: false
    t.integer "task_id"
    t.integer "user_id"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_reminds_on_task_id"
    t.index ["user_id"], name: "index_task_reminds_on_user_id"
  end

  create_table "task_users", force: :cascade do |t|
    t.integer "task_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_task_users_on_task_id"
    t.index ["user_id"], name: "index_task_users_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.datetime "date"
    t.boolean "done", default: false
    t.datetime "done_at"
    t.integer "doner_id"
    t.boolean "assigned", default: false
    t.integer "st_n", default: 0
    t.integer "st_d", default: 0
    t.integer "effectif", default: 0
    t.integer "priority", default: 3
    t.boolean "important", default: false
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_tasks_on_group_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "user_infos", force: :cascade do |t|
    t.string "name"
    t.string "surname"
    t.string "pseudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.boolean "company", default: false
    t.boolean "registred", default: false
    t.string "color"
    t.string "initial"
    t.string "name"
    t.string "surname"
    t.string "pseudo"
    t.integer "pend_notif", default: 0
    t.integer "pend_invit", default: 0
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_votes_on_answer_id"
    t.index ["question_id"], name: "index_votes_on_question_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

end
