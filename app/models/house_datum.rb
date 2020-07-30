class HouseDatum < ApplicationRecord
	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			# IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
			data = find_by(id: row["ID"]) || new
			# CSVからデータを取得し、設定する
			data.attributes = row.to_hash.slice(*updatable_attributes)
			# 保存する
			data.save
		end
	end

	# 更新を許可するカラムを定義
  def self.updatable_attributes
    ["Firstname", "Lastname", "City", "num_of_people", "has_child", "created_at", "updated_at"]
	end
end
