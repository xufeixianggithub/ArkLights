-- debug option, should be commented in release
-- predebug = true
-- no_dorm = true
-- test_some = true
-- test_fight = true
-- no_config_cache = true
-- prefer_bapp = true
-- verbose_fca = true
-- ok_time = 1
-- fake_fight = false
-- fake_fight = true
-- debug0721 = false
-- no_background_after_run = true
-- longest_tag = false
screen = getScreen()
if screen.width < screen.height then
  screen.width, screen.height = screen.height, screen.width
end

require("util")
require("point")
require("path")
require("tag")
log(time() .. " 分辨率：" .. screen.width .. "x" .. screen.height)

-- auto switch 官服 and B服
appid_need_user_select = false
appid = "com.hypergryph.arknights"
bppid = "com.hypergryph.arknights.bilibili"
if prefer_bapp then appid = bppid end
local app_info = getAppinfo(appid)
local bpp_info = getAppinfo(bppid)
if not app_info and not bpp_info then stop("未安装明日方舟官服或B服") end
if bpp_info and not app_info then appid = bppid end
if bpp_info and app_info then appid_need_user_select = true end

if predebug then
  exit()
  local swipd = function()
    local duration = 333
    local delay = 100
    local y1 = screen.height * 3 // 4
    local x1 = math.round((1880 - 1920) * minscale) + screen.width
    local x2 = math.round((680 - 1920) * minscale) + screen.width
    local y2 = math.round(10 * minscale)
    log(x1, y1, x2, y2)
    local paths = {{{x = x1, y = y1}, {x = x1, y = y2}}}
    log(paths)
    gesture(paths, duration)
    sleep(duration + delay)
    tap("入驻干员右侧")
    sleep(50)
  end
  swipd()
  exit()
  -- log(same_page_fight("M9-1","8-2"))
  x0 = 'R8-2'
  swip(x0)
  tap("作战列表" .. x0)
  exit()
end

local outside = runThread("outside")

local all_job = {
  "邮件收取", "轮次作战", "基建收获", "基建换班",
  "副手换人", "制造加速", "线索搜集", "信用购买",
  "公招刷新", "任务收集",
}
local now_job = shallowCopy(all_job)

local parse_id_to_ui = function(prefix, length)
  local ans = ''
  for i = 1, length do ans = ans .. prefix .. i .. '|' end
  return ans:sub(1, #ans - 1)
end

local parse_value_to_ui = function(all, select)
  local ans = ''
  for _, v in pairs(all) do
    if table.includes(select, v) then ans = ans .. '*' end
    ans = ans .. v .. '|'
  end
  return ans:sub(1, #ans - 1)
end

local parse_from_ui = function(prefix, reference)
  local ans = {}
  for i = 1, #reference do
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end

local ui = {
  title = "明日方舟全日常代理",
  cache = not no_config_cache,
  width = -1,
  height = -1,
  time = ok_time or 0,
  views = {
    {title = "账号", type = "edit", id = "username"},
    {title = "密码", type = "edit", id = "password", mode = "password"}, {
      title = "轮次作战地图",
      type = "edit",
      value = "R8-2,PR-D-2,RP-D-1,CE-5,LS-5",
      id = "fight",
    }, {
      type = "check",
      value = "*吃药|吃石头|*保底最高4星时自动招募",
      ore = 1,
      id = "drug_enable|stone_enable|star4_auto",
    }, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, now_job),
      id = parse_id_to_ui("now_job_ui", #all_job),
    }, {
      type = 'div',
      title = '',
      views = {
        {
          type = "button",
          value = "视频演示",
          title = '',
          click = {thread = outside, name = "goto_bilibili"},
        }, {
          type = "button",
          value = "QQ群(1009619697)",
          title = '',
          click = {thread = outside, name = "goto_qq"},
        }, {
          type = "button",
          value = "源码",
          title = '',
          click = {thread = outside, name = "goto_github"},
        },
      },
    },
  },
  submit = {type = "text", value = "启动"},
  cancle = {type = "text", value = "退出"},
};
-- add server selection to ui
if appid_need_user_select then
  table.insert(ui.views, 3, {
    title = "",
    type = "radio",
    value = "*官服|B服",
    ore = 2,
    id = "server",
  })
end

ret = show(ui)
if not ret then exit() end
callThreadFun(outside, "preload")

if server == "B服" then appid = bppid end
log(appid)

now_job = parse_from_ui("now_job_ui", all_job)

fight = string.map(fight, {
  [","] = " ",
  ["、"] = " ",
  ["，"] = " ",
  ["|"] = " ",
  ["\n"] = " ",
  ["\t"] = " ",
})
fight = string.split(fight, ' ')
for _, v in pairs(fight) do
  if table.includes(table.keys(jianpin2name), v) then
    fight[k] = jianpin2name[v]
  end
end
fight = map(string.upper, fight)
fight = table.filter(fight, function(v) return point['作战列表' .. v] end)

all_open_time_start = parse_time("202007151600")
all_open_time_end = parse_time("202007170400")
update_open_time()

if test_fight then
  fight = {
    "JT8-3",
    "JT8-2",
    -- "积水潮窟",
    -- "切尔诺伯格",
    -- "龙门外环",
    -- "龙门市区",
    -- "废弃矿区",
    -- "大骑士领郊外",
    -- "北原冰封废城",

    -- "PR-A-1", "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3","CA-4", "CA-5",
    -- "AP-1", "AP-2", "AP-3", "AP-4", "AP-5", 
    -- "LS-1", "LS-2", "LS-3", "LS-4", "LS-5",
    -- "SK-1", "SK-2", "SK-3", "SK-4", "SK-5",
    -- "0-1", "0-2", "0-3", "0-4", "0-5", "0-6", "0-7", "0-8", "0-9", "0-10",
    -- "0-11", "1-1", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9", "1-10",
    -- "1-11", "1-12", "2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8",
    -- "2-9", "2-10", "S2-1", "S2-2", "S2-3", "S2-4", "S2-5", "S2-6", "S2-7",
    -- "S2-8", "S2-9", "S2-10", "S2-12", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6",
    -- "3-7", "3-8", "S3-1", "S3-2", "S3-3", "S3-4", "S3-5", "S3-6", "S3-7", "4-1",
    -- "4-2", "4-3", "4-4", "4-5", "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1",
    -- "S4-2", "S4-3", "S4-4", "S4-5", "S4-6", "S4-7", "S4-8", "S4-9", "S4-10",
    -- "5-1", "5-2", "S5-1", "S5-2", "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4",
    -- "5-7", "5-8", "5-9", "S5-5", "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1",
    -- "6-2", "6-3", "6-4", "6-5", "6-7", "6-8", "6-9", "6-10", "S6-1", "S6-2",
    -- "6-11", "6-12", "6-14", "6-15", "S6-3", "S6-4", "6-16", "7-2", "7-3", "7-4",
    -- "7-5", "7-6", "7-8", "7-9", "7-10", "7-11", "7-12", "7-13", "7-14", "7-15",
    -- "7-16", "S7-1", "S7-2", "7-17", "7-18", "R8-1", "R8-2", "R8-3", "R8-4",
    -- "R8-5", "R8-6", "R8-7", "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3",
    -- "M8-6", "M8-7", "M8-8",
  }

  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  log(fight)
  repeat_fight_mode = false
  run("轮次作战")
  exit()
end
if test_some then
  -- debug
  logConfig({mode = 3})
  fight = {"1-7", "1-7", "1-6", "JT8-3"}
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  run("邮件收取", "轮次作战", "基建收获", "基建换班",
      "副手换人", "制造加速", "线索搜集", "信用购买",
      "公招刷新", "任务收集")
end

run(now_job)
-- if #cron_job > 0 then cron(cron_job) end
