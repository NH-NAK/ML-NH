package com.example.app

import android.os.Bundle
import android.widget.Button
import android.widget.GridView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView

data class Hero(val name: String, val role: String, val iconResId: Int)

class HeroSkillActivity : AppCompatActivity() {

    private lateinit var searchView: SearchView
    private lateinit var gridView: GridView
    private val fullHeroList = mutableListOf<Hero>()
    private val displayedList = mutableListOf<Hero>()

    private var selectedRole: String = "All"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_hero_skill)

        searchView = findViewById(R.id.searchHero)
        gridView = findViewById(R.id.gridHeroes)

        loadSampleData()
        displayedList.addAll(fullHeroList)

        setupFilters()
        setupSearch()
    }

    private fun loadSampleData() {
        fullHeroList.add(Hero("Tigreal", "Tank", 0))
        fullHeroList.add(Hero("Chou", "Fighter", 0))
        fullHeroList.add(Hero("Gusion", "Assassin", 0))
        fullHeroList.add(Hero("Kagura", "Mage", 0))
        fullHeroList.add(Hero("Granger", "Marksman", 0))
        fullHeroList.add(Hero("Angela", "Support", 0))
    }

    private fun setupFilters() {
        val filterButtons = mapOf(
            R.id.btnAll to "All",
            R.id.btnTank to "Tank",
            R.id.btnFighter to "Fighter",
            R.id.btnAssassin to "Assassin",
            R.id.btnMage to "Mage",
            R.id.btnMarksman to "Marksman",
            R.id.btnSupport to "Support"
        )

        for ((btnId, role) in filterButtons) {
            findViewById<Button>(btnId).setOnClickListener {
                selectedRole = role
                applyFilter(searchView.query.toString())
            }
        }
    }

    private fun setupSearch() {
        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean = false

            override fun onQueryTextChange(newText: String?): Boolean {
                applyFilter(newText.orEmpty())
                return true
            }
        })
    }

    private fun applyFilter(query: String) {
        displayedList.clear()
        val filtered = fullHeroList.filter { hero ->
            val matchesRole = (selectedRole == "All" || hero.role.equals(selectedRole, ignoreCase = true))
            val matchesQuery = hero.name.contains(query, ignoreCase = true)
            matchesRole && matchesQuery
        }
        displayedList.addAll(filtered)
    }
}
