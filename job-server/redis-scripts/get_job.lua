local function generateJob()
	local from = tonumber(redis.pcall('get', 'from')) or 0
	local to = tonumber(redis.pcall('get', 'to')) or 0

	if from == to then
		return nil
	end

	redis.pcall('rpush', 'pendingJobs', from)
	redis.pcall('del', 'job:'..from)
	redis.pcall('set', 'from', from + 1)

	return tostring(from)
end

local function getExpiredJob()
	local currentIndex = 0

	while true do
		local job = redis.pcall('lindex', 'pendingJobs', currentIndex)
		if job == false then
			return nil
		end
		local jobPending = redis.pcall('exists', 'job:'..job)
		if tonumber(jobPending) == 0 then
			return job
		end
		currentIndex = currentIndex + 1
	end
end

local function getJobs(num, expirationTime)
	local jobs = {}

	while table.getn(jobs) < num do
		local job = getExpiredJob() or generateJob()
		if job == nil then
			break;
		end
		redis.pcall('setex', 'job:'..job, expirationTime, job)
		table.insert(jobs, job)
	end

	return jobs;
end

return table.concat(getJobs(tonumber(ARGV[1]), tonumber(ARGV[2])), '\n')